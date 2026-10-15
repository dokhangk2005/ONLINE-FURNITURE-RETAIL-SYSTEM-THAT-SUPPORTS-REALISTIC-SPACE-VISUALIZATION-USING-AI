using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using System;
using furniture_BE.Extensions;
using furniture_BE.Services;
using System.Security.Cryptography;
using System.Text;

namespace furniture_BE.Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DeliveryController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly DeliveryRealtimeNotifier _notifier;
        private readonly SmtpEmailService _email;

        public DeliveryController(
            AppDbContext context,
            DeliveryRealtimeNotifier notifier,
            SmtpEmailService email)
        {
            _context = context;
            _notifier = notifier;
            _email = email;
        }

        // GET: api/delivery/admin-overview
        [HttpGet("admin-overview")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminOverview()
        {
            // 1. Calculate general stats from active orders (not cancelled)
            var allOrders = await _context.Orders
                .Where(o => o.OrderStatus != "Cancelled")
                .ToListAsync();

            decimal totalShippingFees = allOrders.Sum(o => o.ShippingFee);
            decimal totalAssemblyFees = allOrders.Where(o => o.IncludesAssembly).Sum(o => o.AssemblyFee);
            double totalDistanceKm = allOrders.Sum(o => o.DeliveryDistanceKm ?? 0);
            int activeDeliveryCount = allOrders.Count(o => DeliveryStatuses.Active.Contains(o.OrderStatus));

            // 2. Calculate Shippers workload (RoleId == 3)
            var shippers = await _context.Users
                .Where(u => u.RoleId == 3 && !u.IsDeleted)
                .Select(u => new
                {
                    u.UserId,
                    u.FullName,
                    u.Phone,
                    u.Email,
                    u.IsAvailableForDelivery,
                    u.AvailabilityUpdatedAt,
                    u.DeliveryShiftStatus,
                    u.DeliveryVehicleType,
                    u.DeliveryVehiclePlate,
                    u.DeliveryServiceArea,
                    u.CanHandleBulkyItems,
                    u.CanProvideAssembly,
                    u.MaxConcurrentDeliveries,
                    ActiveOrdersCount = _context.Orders.Count(o => o.ShipperId == u.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus)),
                    CompletedOrdersCount = _context.Orders.Count(o => o.ShipperId == u.UserId && o.OrderStatus == "Delivered")
                })
                .ToListAsync();

            var shipperWorkloads = shippers.Select(s => new
            {
                s.UserId,
                s.FullName,
                s.Phone,
                s.Email,
                s.ActiveOrdersCount,
                s.CompletedOrdersCount,
                s.IsAvailableForDelivery,
                s.AvailabilityUpdatedAt,
                s.DeliveryShiftStatus,
                s.DeliveryVehicleType,
                s.DeliveryVehiclePlate,
                s.DeliveryServiceArea,
                s.CanHandleBulkyItems,
                s.CanProvideAssembly,
                s.MaxConcurrentDeliveries,
                Status = s.DeliveryShiftStatus switch
                {
                    DeliveryShiftStatuses.Available => "Sẵn sàng",
                    DeliveryShiftStatuses.Delivering => "Đang giao",
                    DeliveryShiftStatuses.Break => "Tạm nghỉ",
                    _ => "Ngoại tuyến"
                },
                WorkloadStatus = s.ActiveOrdersCount == 0 ? "Chưa có đơn" : $"Đang giao {s.ActiveOrdersCount} đơn"
            }).ToList();

            // 3. Fetch detailed logistics orders (all orders that are relevant to shipping/delivery/rescheduled/delivered)
            var orders = await _context.Orders
                .Include(o => o.Shipper)
                .Include(o => o.User)
                .Where(o => DeliveryStatuses.Active.Contains(o.OrderStatus) || o.OrderStatus == "Delivered" || o.OrderStatus == "Cancelled" || o.OrderStatus == "Pending" || o.OrderStatus == "Processing")
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new
                {
                    o.OrderId,
                    o.OrderCode,
                    o.OrderStatus,
                    o.OrderDate,
                    o.ShippingAddress,
                    o.TotalAmount,
                    o.ShippingFee,
                    o.AssemblyFee,
                    o.IncludesAssembly,
                    o.DeliveryDistanceKm,
                    o.EstimatedDeliveryDate,
                    o.DeliveryTimeSlot,
                    o.ShipperId,
                    ShipperName = o.Shipper != null ? o.Shipper.FullName : "Chưa phân công",
                    UserFullName = o.RecipientName != "" ? o.RecipientName : (o.User != null ? o.User.FullName : "Khách hàng"),
                    UserPhone = o.RecipientPhone != "" ? o.RecipientPhone : (o.User != null ? o.User.Phone : ""),
                    o.DeliveryProofImage,
                    o.DeliveryNotes,
                    o.DeliveryAttemptCount,
                    o.DeliveryCancelledAt,
                    o.DeliveryCancelledByShipperId,
                    o.DeliveryCancellationReason,
                    o.DeliveryCancellationNote,
                    o.DeliveryCancellationProofImage
                })
                .ToListAsync();

            return Ok(new
            {
                Stats = new
                {
                    TotalShippingFees = totalShippingFees,
                    TotalAssemblyFees = totalAssemblyFees,
                    TotalDistanceKm = Math.Round(totalDistanceKm, 2),
                    ActiveDeliveryCount = activeDeliveryCount
                },
                Shippers = shipperWorkloads,
                Orders = orders
            });
        }

        [HttpGet("shipper/availability")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> GetAvailability()
        {
            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == User.UserId() && u.RoleId == 3);
            if (shipper == null) return NotFound(new { Message = "Không tìm thấy tài khoản shipper." });
            return Ok(new
            {
                shipper.IsAvailableForDelivery,
                shipper.AvailabilityUpdatedAt,
                shipper.DeliveryShiftStatus,
                shipper.DeliveryShiftStartedAt,
                shipper.DeliveryShiftEndedAt,
                shipper.DeliveryBreakUntil
            });
        }

        [HttpPut("shipper/availability")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> UpdateAvailability([FromBody] AvailabilityRequest request)
        {
            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == User.UserId() && u.RoleId == 3);
            if (shipper == null) return NotFound(new { Message = "Không tìm thấy tài khoản shipper." });
            var hasActive = await _context.Orders.AnyAsync(o =>
                o.ShipperId == shipper.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus) &&
                o.OrderStatus != DeliveryStatuses.Assigned);
            if (!request.IsAvailable && hasActive)
                return BadRequest(new { Message = "Không thể kết thúc ca khi còn đơn giao hàng đang xử lý." });
            shipper.IsAvailableForDelivery = request.IsAvailable;
            shipper.DeliveryShiftStatus = request.IsAvailable
                ? (hasActive ? DeliveryShiftStatuses.Delivering : DeliveryShiftStatuses.Available)
                : DeliveryShiftStatuses.Offline;
            if (request.IsAvailable && shipper.DeliveryShiftStartedAt == null)
                shipper.DeliveryShiftStartedAt = DateTime.Now;
            if (!request.IsAvailable)
                shipper.DeliveryShiftEndedAt = DateTime.Now;
            shipper.AvailabilityUpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return Ok(new { shipper.IsAvailableForDelivery, shipper.AvailabilityUpdatedAt, Status = shipper.IsAvailableForDelivery ? "Sẵn sàng" : "Không sẵn sàng" });
        }

        [HttpGet("shipper/profile")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> GetShipperProfile()
        {
            var userId = User.UserId();
            var shipper = await _context.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserId == userId && u.RoleId == 3);
            if (shipper == null) return NotFound(new { Message = "Không tìm thấy tài khoản shipper." });
            var activeCount = await _context.Orders.CountAsync(o =>
                o.ShipperId == userId && DeliveryStatuses.Active.Contains(o.OrderStatus));
            var completedToday = await _context.Orders.CountAsync(o =>
                o.ShipperId == userId && o.OrderStatus == DeliveryStatuses.Delivered &&
                o.DeliveredAt != null && o.DeliveredAt.Value.Date == DateTime.Today);
            return Ok(new
            {
                shipper.UserId,
                shipper.FullName,
                shipper.Email,
                shipper.Phone,
                shipper.DeliveryShiftStatus,
                shipper.DeliveryShiftStartedAt,
                shipper.DeliveryShiftEndedAt,
                shipper.DeliveryBreakUntil,
                shipper.DeliveryVehicleType,
                shipper.DeliveryVehiclePlate,
                shipper.DeliveryServiceArea,
                shipper.CanHandleBulkyItems,
                shipper.CanProvideAssembly,
                shipper.MaxConcurrentDeliveries,
                ActiveDeliveries = activeCount,
                CompletedToday = completedToday
            });
        }

        [HttpPut("shipper/profile")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> UpdateShipperProfile([FromBody] ShipperProfileRequest request)
        {
            var shipper = await _context.Users.FirstOrDefaultAsync(u =>
                u.UserId == User.UserId() && u.RoleId == 3);
            if (shipper == null) return NotFound(new { Message = "Không tìm thấy tài khoản shipper." });
            if (request.MaxConcurrentDeliveries is < 1 or > 20)
                return BadRequest(new { Message = "Số đơn tối đa phải từ 1 đến 20." });

            shipper.DeliveryVehicleType = request.VehicleType?.Trim();
            shipper.DeliveryVehiclePlate = request.VehiclePlate?.Trim().ToUpperInvariant();
            shipper.DeliveryServiceArea = request.ServiceArea?.Trim();
            shipper.CanHandleBulkyItems = request.CanHandleBulkyItems;
            shipper.CanProvideAssembly = request.CanProvideAssembly;
            shipper.MaxConcurrentDeliveries = request.MaxConcurrentDeliveries;
            shipper.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã cập nhật hồ sơ giao hàng." });
        }

        [HttpPut("shipper/shift")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> UpdateShift([FromBody] ShiftRequest request)
        {
            var status = request.Status?.Trim() ?? string.Empty;
            if (!DeliveryShiftStatuses.IsValid(status))
                return BadRequest(new { Message = "Trạng thái ca làm việc không hợp lệ." });

            var userId = User.UserId();
            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId && u.RoleId == 3);
            if (shipper == null) return NotFound(new { Message = "Không tìm thấy tài khoản shipper." });
            var hasActive = await _context.Orders.AnyAsync(o =>
                o.ShipperId == userId && DeliveryStatuses.Active.Contains(o.OrderStatus) &&
                o.OrderStatus != DeliveryStatuses.Assigned);
            if (status.Equals(DeliveryShiftStatuses.Offline, StringComparison.OrdinalIgnoreCase) && hasActive)
                return BadRequest(new { Message = "Hãy hoàn tất hoặc bàn giao đơn đang xử lý trước khi kết thúc ca." });
            if (status.Equals(DeliveryShiftStatuses.Available, StringComparison.OrdinalIgnoreCase) && hasActive)
                return BadRequest(new { Message = "Bạn đang xử lý đơn hàng; trạng thái ca phải là Đang giao hoặc Tạm nghỉ." });

            shipper.DeliveryShiftStatus = status;
            shipper.IsAvailableForDelivery = status.Equals(DeliveryShiftStatuses.Available, StringComparison.OrdinalIgnoreCase);
            shipper.AvailabilityUpdatedAt = DateTime.Now;
            shipper.DeliveryBreakUntil = status.Equals(DeliveryShiftStatuses.Break, StringComparison.OrdinalIgnoreCase)
                ? request.BreakUntil
                : null;
            if (status.Equals(DeliveryShiftStatuses.Available, StringComparison.OrdinalIgnoreCase) &&
                shipper.DeliveryShiftStartedAt == null)
                shipper.DeliveryShiftStartedAt = DateTime.Now;
            if (status.Equals(DeliveryShiftStatuses.Offline, StringComparison.OrdinalIgnoreCase))
            {
                shipper.DeliveryShiftEndedAt = DateTime.Now;
                shipper.DeliveryShiftStartedAt = null;
            }
            await _context.SaveChangesAsync();
            return Ok(new
            {
                shipper.DeliveryShiftStatus,
                shipper.IsAvailableForDelivery,
                shipper.DeliveryBreakUntil
            });
        }

        [HttpPost("shipper/{orderId:int}/accept")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> AcceptAssignment(int orderId)
        {
            var order = await FindAssignedOrder(orderId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn được phân công." });
            if (order.OrderStatus != DeliveryStatuses.Assigned && order.OrderStatus != DeliveryStatuses.Rescheduled)
                return BadRequest(new { Message = "Đơn hàng không ở trạng thái chờ shipper nhận." });
            if (order.DeliveryAssignmentExpiresAt < DateTime.Now)
                return BadRequest(new { Message = "Yêu cầu phân công đã hết hạn. Vui lòng liên hệ Admin." });

            order.OrderStatus = DeliveryStatuses.Accepted;
            order.DeliveryAcceptedAt = DateTime.Now;
            order.UpdatedAt = DateTime.Now;
            await SetShipperDelivering();
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(orderId, "Shipper đã chấp nhận đơn giao hàng.");
            return Ok(new { Message = "Đã chấp nhận đơn giao hàng." });
        }

        [HttpPost("shipper/{orderId:int}/reject")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> RejectAssignment(int orderId, [FromBody] RejectAssignmentRequest request)
        {
            var order = await FindAssignedOrder(orderId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn được phân công." });
            if (order.OrderStatus != DeliveryStatuses.Assigned)
                return BadRequest(new { Message = "Chỉ có thể từ chối đơn đang chờ tiếp nhận." });
            if (string.IsNullOrWhiteSpace(request.Reason))
                return BadRequest(new { Message = "Vui lòng chọn lý do từ chối." });

            order.DeliveryNotes = PrependNote(order.DeliveryNotes, $"Shipper từ chối: {request.Reason.Trim()}");
            var rejectedShipperId = order.ShipperId;
            order.OrderStatus = "Processing";
            order.ShipperId = null;
            order.DeliveryAssignedAt = null;
            order.DeliveryAssignmentExpiresAt = null;
            order.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(orderId, "Shipper đã từ chối; đơn hàng cần được phân công lại.", rejectedShipperId);
            return Ok(new { Message = "Đã từ chối và chuyển đơn về Admin." });
        }

        [HttpPut("shipper/{orderId:int}/status")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> UpdateDeliveryStatus(int orderId, [FromBody] DeliveryStatusRequest request)
        {
            var order = await FindAssignedOrder(orderId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn giao hàng." });
            var next = request.Status?.Trim() ?? string.Empty;
            if (!DeliveryStatuses.CanTransition(order.OrderStatus, next) ||
                next == DeliveryStatuses.Delivered)
                return BadRequest(new { Message = $"Không thể chuyển từ {order.OrderStatus} sang {next}." });

            order.OrderStatus = next;
            order.UpdatedAt = DateTime.Now;
            if (next == DeliveryStatuses.PickedUp) order.DeliveryPickedUpAt = DateTime.Now;
            if (next == DeliveryStatuses.Arrived) order.DeliveryArrivedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(orderId, StatusMessage(next));
            return Ok(new { order.OrderStatus, Message = StatusMessage(next) });
        }

        [HttpPost("shipper/{orderId:int}/otp/request")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> RequestDeliveryOtp(int orderId)
        {
            var order = await _context.Orders.Include(o => o.User)
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.ShipperId == User.UserId());
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn giao hàng." });
            if (order.OrderStatus != DeliveryStatuses.Arrived)
                return BadRequest(new { Message = "Chỉ gửi OTP sau khi shipper đã đến nơi." });
            var recipientEmail = string.IsNullOrWhiteSpace(order.RecipientEmail)
                ? order.User?.Email
                : order.RecipientEmail;
            if (string.IsNullOrWhiteSpace(recipientEmail))
                return BadRequest(new { Message = "Đơn hàng không có email người nhận." });
            if (order.DeliveryOtpHash != null && order.DeliveryOtpExpiresAt > DateTime.Now.AddMinutes(9))
                return StatusCode(StatusCodes.Status429TooManyRequests, new { Message = "Vui lòng chờ một phút trước khi gửi lại OTP." });

            var otp = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
            order.DeliveryOtpHash = HashOtp(order.OrderId, otp);
            order.DeliveryOtpExpiresAt = DateTime.Now.AddMinutes(10);
            order.DeliveryOtpVerifiedAt = null;
            order.DeliveryOtpAttempts = 0;
            await _email.SendDeliveryOtpAsync(
                recipientEmail,
                order.RecipientName,
                order.OrderCode ?? $"#{order.OrderId}",
                otp,
                order.DeliveryOtpExpiresAt.Value);
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Đã gửi OTP giao hàng qua email.", ExpiresAt = order.DeliveryOtpExpiresAt });
        }

        [HttpPost("shipper/{orderId:int}/otp/verify")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> VerifyDeliveryOtp(int orderId, [FromBody] VerifyOtpRequest request)
        {
            var order = await FindAssignedOrder(orderId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn giao hàng." });
            if (order.DeliveryOtpVerifiedAt != null)
                return Ok(new { Message = "OTP đã được xác minh.", Verified = true });
            if (order.DeliveryOtpExpiresAt == null || order.DeliveryOtpExpiresAt < DateTime.Now)
                return BadRequest(new { Message = "OTP đã hết hạn." });
            if (order.DeliveryOtpAttempts >= 5)
                return BadRequest(new { Message = "Đã vượt quá số lần nhập OTP." });

            order.DeliveryOtpAttempts += 1;
            if (!CryptographicOperations.FixedTimeEquals(
                    Encoding.UTF8.GetBytes(order.DeliveryOtpHash ?? string.Empty),
                    Encoding.UTF8.GetBytes(HashOtp(orderId, request.Otp ?? string.Empty))))
            {
                await _context.SaveChangesAsync();
                return BadRequest(new { Message = "OTP không chính xác." });
            }
            order.DeliveryOtpVerifiedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Xác minh OTP thành công.", Verified = true });
        }

        [HttpPost("shipper/{orderId:int}/payment/collect")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> ConfirmPaymentCollection(
            int orderId,
            [FromBody] CollectPaymentRequest request)
        {
            var shipperId = User.UserId();
            var order = await _context.Orders
                .Include(o => o.Payments)
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.ShipperId == shipperId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn giao hàng." });
            if (order.OrderStatus != DeliveryStatuses.Arrived)
                return BadRequest(new { Message = "Chỉ xác nhận thu tiền sau khi đã đến nơi giao hàng." });

            var payment = order.Payments.OrderByDescending(p => p.PaymentId).FirstOrDefault();
            if (payment == null) return BadRequest(new { Message = "Đơn hàng chưa có thông tin thanh toán." });
            if (!IsCollectOnDelivery(payment.PaymentMethod))
                return BadRequest(new { Message = "Phương thức thanh toán này không yêu cầu shipper thu tiền." });
            if (payment.CollectedAt != null)
            {
                return Ok(new
                {
                    Message = "Khoản thanh toán đã được xác nhận thu trước đó.",
                    payment.CollectedAt,
                    payment.HandoverStatus
                });
            }

            var now = DateTime.Now;
            payment.CollectedByShipperId = shipperId;
            payment.CollectedAt = now;
            payment.CollectionProofImage = request.ProofImage?.Trim();
            payment.CollectionNote = request.Note?.Trim();
            payment.HandoverStatus = PaymentHandoverStatuses.Pending;
            payment.PaymentStatus = "Success";
            payment.PaymentDate = now;
            payment.UpdatedAt = now;
            _context.PaymentReconciliationHistories.Add(new PaymentReconciliationHistory
            {
                PaymentId = payment.PaymentId,
                OrderId = order.OrderId,
                ShipperId = shipperId,
                Action = PaymentReconciliationActions.Collected,
                Status = PaymentHandoverStatuses.Pending,
                Amount = payment.Amount,
                ProofImage = payment.CollectionProofImage,
                Note = payment.CollectionNote,
                CreatedAt = now
            });
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(orderId, "Shipper đã xác nhận thu tiền thanh toán.");
            return Ok(new
            {
                Message = "Đã xác nhận thu tiền từ khách hàng.",
                payment.Amount,
                payment.CollectedAt,
                payment.HandoverStatus
            });
        }

        [HttpGet("shipper/reconciliation")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> GetShipperReconciliation(
            [FromQuery] string period = "day",
            [FromQuery] DateTime? anchor = null)
        {
            var shipperId = User.UserId();
            var (start, end, normalizedPeriod) = ResolvePeriod(period, anchor);
            var payments = await _context.Payments.AsNoTracking()
                .Include(p => p.Order)
                .Where(p => p.CollectedByShipperId == shipperId &&
                            p.CollectedAt >= start && p.CollectedAt < end)
                .OrderByDescending(p => p.CollectedAt)
                .ToListAsync();
            var paymentIds = payments.Select(p => p.PaymentId).ToList();
            var history = await _context.PaymentReconciliationHistories.AsNoTracking()
                .Where(h => paymentIds.Contains(h.PaymentId))
                .OrderByDescending(h => h.CreatedAt)
                .Select(h => new
                {
                    h.PaymentReconciliationHistoryId,
                    h.PaymentId,
                    h.OrderId,
                    h.Action,
                    h.Status,
                    h.Amount,
                    h.ProofImage,
                    h.Note,
                    h.CreatedAt,
                    h.AdminId
                })
                .ToListAsync();

            return Ok(new
            {
                Period = normalizedPeriod,
                Start = start,
                End = end,
                CollectedCount = payments.Count,
                CollectedAmount = payments.Sum(p => p.Amount),
                PendingCount = payments.Count(p => p.HandoverStatus == PaymentHandoverStatuses.Pending || p.HandoverStatus == PaymentHandoverStatuses.Rejected),
                PendingAmount = payments.Where(p => p.HandoverStatus == PaymentHandoverStatuses.Pending || p.HandoverStatus == PaymentHandoverStatuses.Rejected).Sum(p => p.Amount),
                SubmittedCount = payments.Count(p => p.HandoverStatus == PaymentHandoverStatuses.Submitted),
                SubmittedAmount = payments.Where(p => p.HandoverStatus == PaymentHandoverStatuses.Submitted).Sum(p => p.Amount),
                ConfirmedCount = payments.Count(p => p.HandoverStatus == PaymentHandoverStatuses.Confirmed),
                ConfirmedAmount = payments.Where(p => p.HandoverStatus == PaymentHandoverStatuses.Confirmed).Sum(p => p.Amount),
                Entries = payments.Select(p => new
                {
                    p.PaymentId,
                    p.OrderId,
                    p.Order.OrderCode,
                    p.PaymentMethod,
                    p.Amount,
                    p.CollectedAt,
                    p.CollectionProofImage,
                    p.CollectionNote,
                    p.HandoverStatus,
                    p.HandoverSubmittedAt,
                    p.HandoverConfirmedAt
                }),
                History = history
            });
        }

        [HttpPost("shipper/reconciliation/submit")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> SubmitReconciliation([FromBody] SubmitReconciliationRequest request)
        {
            var shipperId = User.UserId();
            var query = _context.Payments.Where(p =>
                p.CollectedByShipperId == shipperId &&
                (p.HandoverStatus == PaymentHandoverStatuses.Pending ||
                 p.HandoverStatus == PaymentHandoverStatuses.Rejected));
            if (request.PaymentIds is { Count: > 0 })
                query = query.Where(p => request.PaymentIds.Contains(p.PaymentId));
            var payments = await query.ToListAsync();
            if (payments.Count == 0)
                return BadRequest(new { Message = "Không có khoản thu nào đang chờ bàn giao." });

            var now = DateTime.Now;
            foreach (var payment in payments)
            {
                payment.HandoverStatus = PaymentHandoverStatuses.Submitted;
                payment.HandoverSubmittedAt = now;
                payment.UpdatedAt = now;
                _context.PaymentReconciliationHistories.Add(new PaymentReconciliationHistory
                {
                    PaymentId = payment.PaymentId,
                    OrderId = payment.OrderId,
                    ShipperId = shipperId,
                    Action = PaymentReconciliationActions.Submitted,
                    Status = PaymentHandoverStatuses.Submitted,
                    Amount = payment.Amount,
                    Note = request.Note?.Trim(),
                    CreatedAt = now
                });
            }
            await _context.SaveChangesAsync();
            return Ok(new
            {
                Message = "Đã gửi yêu cầu xác nhận bàn giao tiền cho Admin.",
                Count = payments.Count,
                Amount = payments.Sum(p => p.Amount)
            });
        }

        [HttpGet("admin/reconciliations")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminReconciliations([FromQuery] string? status = null)
        {
            var query = _context.Payments.AsNoTracking()
                .Include(p => p.Order)
                .Include(p => p.CollectedByShipper)
                .Where(p => p.CollectedAt != null &&
                    (p.PaymentMethod == "COD" || p.PaymentMethod == "POS"));
            if (!string.IsNullOrWhiteSpace(status))
            {
                var normalized = status.Trim();
                query = query.Where(p => p.HandoverStatus == normalized);
            }
            var entries = await query.OrderByDescending(p => p.HandoverSubmittedAt ?? p.CollectedAt)
                .Select(p => new
                {
                    p.PaymentId,
                    p.OrderId,
                    p.Order.OrderCode,
                    p.PaymentMethod,
                    p.Amount,
                    p.PaymentStatus,
                    p.CollectedByShipperId,
                    ShipperName = p.CollectedByShipper != null ? p.CollectedByShipper.FullName : "Shipper",
                    p.CollectedAt,
                    p.CollectionProofImage,
                    p.CollectionNote,
                    p.HandoverStatus,
                    p.HandoverSubmittedAt,
                    p.HandoverConfirmedAt,
                    p.HandoverConfirmedByAdminId
                })
                .ToListAsync();
            return Ok(entries);
        }

        [HttpPost("admin/reconciliation/{paymentId:int}/confirm")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ConfirmReconciliation(
            int paymentId,
            [FromBody] ReconciliationDecisionRequest request)
        {
            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.PaymentId == paymentId);
            if (payment == null) return NotFound(new { Message = "Không tìm thấy khoản thu." });
            if (!payment.CollectedByShipperId.HasValue)
                return BadRequest(new { Message = "Khoản thu không có thông tin shipper." });
            if (payment.HandoverStatus != PaymentHandoverStatuses.Submitted)
                return BadRequest(new { Message = "Khoản thu chưa được shipper gửi bàn giao." });

            var now = DateTime.Now;
            var adminId = User.UserId();
            payment.HandoverStatus = PaymentHandoverStatuses.Confirmed;
            payment.HandoverConfirmedAt = now;
            payment.HandoverConfirmedByAdminId = adminId;
            payment.UpdatedAt = now;
            _context.PaymentReconciliationHistories.Add(new PaymentReconciliationHistory
            {
                PaymentId = payment.PaymentId,
                OrderId = payment.OrderId,
                ShipperId = payment.CollectedByShipperId.Value,
                AdminId = adminId,
                Action = PaymentReconciliationActions.Confirmed,
                Status = PaymentHandoverStatuses.Confirmed,
                Amount = payment.Amount,
                Note = request.Note?.Trim(),
                CreatedAt = now
            });
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(payment.OrderId, "Admin đã xác nhận shipper bàn giao tiền.");
            return Ok(new { Message = "Đã xác nhận bàn giao tiền." });
        }

        [HttpPost("admin/reconciliation/{paymentId:int}/reject")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RejectReconciliation(
            int paymentId,
            [FromBody] ReconciliationDecisionRequest request)
        {
            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.PaymentId == paymentId);
            if (payment == null) return NotFound(new { Message = "Không tìm thấy khoản thu." });
            if (!payment.CollectedByShipperId.HasValue)
                return BadRequest(new { Message = "Khoản thu không có thông tin shipper." });
            if (payment.HandoverStatus != PaymentHandoverStatuses.Submitted)
                return BadRequest(new { Message = "Khoản thu chưa được shipper gửi bàn giao." });
            if (string.IsNullOrWhiteSpace(request.Note))
                return BadRequest(new { Message = "Vui lòng nhập lý do từ chối đối soát." });

            var now = DateTime.Now;
            var adminId = User.UserId();
            payment.HandoverStatus = PaymentHandoverStatuses.Rejected;
            payment.HandoverSubmittedAt = null;
            payment.UpdatedAt = now;
            _context.PaymentReconciliationHistories.Add(new PaymentReconciliationHistory
            {
                PaymentId = payment.PaymentId,
                OrderId = payment.OrderId,
                ShipperId = payment.CollectedByShipperId.Value,
                AdminId = adminId,
                Action = PaymentReconciliationActions.Rejected,
                Status = PaymentHandoverStatuses.Rejected,
                Amount = payment.Amount,
                Note = request.Note.Trim(),
                CreatedAt = now
            });
            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(payment.OrderId, "Admin yêu cầu shipper kiểm tra lại khoản bàn giao tiền.");
            return Ok(new { Message = "Đã trả lại khoản đối soát cho shipper." });
        }

        [HttpGet("shipper/performance")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> GetShipperPerformance(
            [FromQuery] string period = "day",
            [FromQuery] DateTime? anchor = null)
        {
            return Ok(await BuildPerformanceAsync(User.UserId(), period, anchor));
        }

        [HttpGet("admin/shipper-performance")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminShipperPerformance(
            [FromQuery] string period = "week",
            [FromQuery] DateTime? anchor = null)
        {
            var shippers = await _context.Users.AsNoTracking()
                .Where(u => u.RoleId == 3 && !u.IsDeleted)
                .Select(u => new { u.UserId, u.FullName })
                .ToListAsync();
            var results = new List<object>();
            foreach (var shipper in shippers)
            {
                results.Add(new
                {
                    shipper.UserId,
                    shipper.FullName,
                    Performance = await BuildPerformanceAsync(shipper.UserId, period, anchor)
                });
            }
            return Ok(results);
        }

        // PUT: api/delivery/shipper/{orderId}/report-issue
        [HttpPut("shipper/{orderId}/report-issue")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> ReportDeliveryIssue(int orderId, [FromBody] ReportIssueRequest request)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order != null && order.ShipperId != User.UserId()) return Forbid();
            if (order == null)
                return NotFound(new { Message = "Không tìm thấy đơn hàng." });
            if (!DeliveryStatuses.Active.Contains(order.OrderStatus) || order.OrderStatus == DeliveryStatuses.Assigned)
                return BadRequest(new { Message = "Chỉ báo cáo sự cố sau khi đã tiếp nhận đơn và trước khi hoàn tất." });
            if (string.IsNullOrWhiteSpace(request.Reason))
                return BadRequest(new { Message = "Vui lòng chọn lý do sự cố." });

            order.OrderStatus = "Rescheduled";
            order.DeliveryAttemptCount += 1;
            if (!string.IsNullOrWhiteSpace(request.ProofImage))
                order.DeliveryIssueProofImage = request.ProofImage.Trim();
            
            string timeStr = DateTime.Now.ToString("dd/MM HH:mm");
            string noteEntry = $"[{timeStr} - {request.Reason}] {request.Note}";
            if (string.IsNullOrEmpty(order.DeliveryNotes))
            {
                order.DeliveryNotes = noteEntry;
            }
            else
            {
                order.DeliveryNotes = $"{noteEntry}\n{order.DeliveryNotes}";
            }

            order.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            await _notifier.OrderUpdatedAsync(orderId, "Shipper đã báo sự cố giao hàng.");
            return Ok(new { Message = "Đã báo cáo sự cố & ghi nhận yêu cầu hẹn giao lại!" });
        }

        // PUT: api/delivery/shipper/{orderId}/cancel
        [HttpPut("shipper/{orderId}/cancel")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> CancelOrderByShipper(
            int orderId,
            [FromBody] CancelDeliveryRequest request)
        {
            var shipperId = User.UserId();
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.Payments)
                .FirstOrDefaultAsync(o => o.OrderId == orderId && o.ShipperId == shipperId);
            if (order == null)
                return NotFound(new { Message = "Không tìm thấy đơn giao hàng được phân công cho bạn." });
            if (!DeliveryStatuses.Active.Contains(order.OrderStatus))
                return BadRequest(new { Message = "Chỉ có thể hủy đơn đang trong quá trình giao." });
            if (string.IsNullOrWhiteSpace(request.Reason))
                return BadRequest(new { Message = "Vui lòng chọn lý do hủy đơn." });

            var payment = order.Payments.OrderByDescending(p => p.PaymentId).FirstOrDefault();
            if (payment?.CollectedAt != null)
                return BadRequest(new { Message = "Đơn đã thu tiền. Hãy liên hệ admin để xử lý hoàn tiền và đối soát." });
            if (payment?.PaymentStatus.Equals("Success", StringComparison.OrdinalIgnoreCase) == true)
                return BadRequest(new { Message = "Đơn đã thanh toán. Shipper không thể tự hủy; vui lòng liên hệ admin để xử lý hoàn tiền." });

            var now = DateTime.Now;
            order.OrderStatus = DeliveryStatuses.Cancelled;
            order.DeliveryCancelledAt = now;
            order.DeliveryCancelledByShipperId = shipperId;
            order.DeliveryCancellationReason = request.Reason.Trim();
            order.DeliveryCancellationNote = request.Note?.Trim();
            order.DeliveryCancellationProofImage = request.ProofImage?.Trim();
            order.DeliveryNotes = PrependNote(
                order.DeliveryNotes,
                $"Shipper hủy đơn: {order.DeliveryCancellationReason}. {order.DeliveryCancellationNote}".Trim());
            order.DeliveryOtpHash = null;
            order.DeliveryOtpExpiresAt = null;
            order.UpdatedAt = now;

            foreach (var detail in order.OrderDetails)
            {
                var variant = await _context.ProductVariants
                    .FirstOrDefaultAsync(v => v.VariantId == detail.VariantId);
                if (variant != null) variant.StockQuantity += detail.Quantity;
            }
            if (!string.IsNullOrWhiteSpace(order.VoucherCode))
            {
                var voucherCode = order.VoucherCode.Trim().ToUpperInvariant();
                var voucher = await _context.Vouchers
                    .FirstOrDefaultAsync(v => v.VoucherCode.ToUpper() == voucherCode);
                if (voucher != null && voucher.UsedCount > 0) voucher.UsedCount--;
            }
            if (payment != null)
            {
                payment.PaymentStatus = "Cancelled";
                payment.UpdatedAt = now;
            }

            await _context.SaveChangesAsync();

            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == shipperId);
            if (shipper != null)
            {
                var remainingActiveCount = await _context.Orders.CountAsync(o =>
                    o.ShipperId == shipperId && DeliveryStatuses.Active.Contains(o.OrderStatus));
                if (shipper.DeliveryShiftStatus == DeliveryShiftStatuses.Delivering && remainingActiveCount == 0)
                    shipper.DeliveryShiftStatus = DeliveryShiftStatuses.Available;
                shipper.IsAvailableForDelivery = remainingActiveCount < shipper.MaxConcurrentDeliveries;
                shipper.AvailabilityUpdatedAt = now;
                await _context.SaveChangesAsync();
            }

            await _notifier.OrderUpdatedAsync(orderId, "Shipper đã hủy đơn giao hàng.");
            return Ok(new { Message = "Đã hủy đơn hàng và lưu lịch sử hủy." });
        }

        // PUT: api/delivery/admin/{orderId}/reschedule
        [HttpPut("admin/{orderId}/reschedule")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RescheduleOrder(int orderId, [FromBody] RescheduleOrderRequest request)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
                return NotFound(new { Message = "Không tìm thấy đơn hàng." });
            if (order.OrderStatus.Equals("Delivered", StringComparison.OrdinalIgnoreCase)
                || order.OrderStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { Message = "Không thể điều phối lại đơn hàng đã hoàn tất hoặc đã hủy." });
            }
            var currentStatus = order.OrderStatus?.Trim() ?? string.Empty;
            var canDispatch = currentStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase)
                || currentStatus.Equals("Processing", StringComparison.OrdinalIgnoreCase)
                || currentStatus.Equals(DeliveryStatuses.Assigned, StringComparison.OrdinalIgnoreCase)
                || currentStatus.Equals(DeliveryStatuses.Rescheduled, StringComparison.OrdinalIgnoreCase);
            if (!canDispatch)
            {
                return BadRequest(new
                {
                    Message = "Shipper đã tiếp nhận đơn. Chỉ có thể điều phối lại sau khi shipper báo sự cố giao hàng."
                });
            }

            if (request.ShipperId == null || request.ShipperId <= 0)
            {
                return BadRequest(new { Message = "Vui lòng bắt buộc chọn Shipper trước khi phân công / điều phối!" });
            }

            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == request.ShipperId && u.RoleId == 3);
            if (shipper == null)
                return BadRequest(new { Message = "Tài khoản Shipper không hợp lệ hoặc không tồn tại." });
            if (!shipper.IsAvailableForDelivery && shipper.DeliveryShiftStatus != DeliveryShiftStatuses.Delivering)
                return BadRequest(new { Message = "Shipper đang ở trạng thái không sẵn sàng." });
            if (order.IncludesAssembly && !shipper.CanProvideAssembly)
                return BadRequest(new { Message = "Shipper này chưa được đánh dấu có khả năng lắp đặt." });
            var activeCount = await _context.Orders.CountAsync(o =>
                o.ShipperId == shipper.UserId && o.OrderId != order.OrderId && DeliveryStatuses.Active.Contains(o.OrderStatus));
            if (activeCount >= shipper.MaxConcurrentDeliveries)
                return BadRequest(new { Message = "Shipper đã đạt số đơn tối đa có thể xử lý." });

            var previousShipperId = order.ShipperId;
            var isInitialAssignment = !previousShipperId.HasValue &&
                (currentStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase)
                 || currentStatus.Equals("Processing", StringComparison.OrdinalIgnoreCase));
            order.ShipperId = request.ShipperId;

            if (request.EstimatedDeliveryDate != null)
            {
                order.EstimatedDeliveryDate = request.EstimatedDeliveryDate;
            }

            if (!string.IsNullOrEmpty(request.DeliveryTimeSlot))
            {
                order.DeliveryTimeSlot = request.DeliveryTimeSlot;
            }

            if (!string.IsNullOrEmpty(request.AdminNote))
            {
                string timeStr = DateTime.Now.ToString("dd/MM HH:mm");
                string adminNote = $"[Admin Điều phối {timeStr}] {request.AdminNote}";
                order.DeliveryNotes = string.IsNullOrEmpty(order.DeliveryNotes) ? adminNote : $"{adminNote}\n{order.DeliveryNotes}";
            }

            // Đưa trạng thái về Shipping / Assigned sau khi điều phối lại thành công
            order.OrderStatus = DeliveryStatuses.Assigned;
            order.DeliveryAssignedAt = DateTime.Now;
            order.DeliveryAssignmentExpiresAt = DateTime.Now.AddMinutes(30);
            order.DeliveryAcceptedAt = null;
            order.DeliveryPickedUpAt = null;
            order.DeliveryArrivedAt = null;
            order.DeliveryOtpHash = null;
            order.DeliveryOtpExpiresAt = null;
            order.DeliveryOtpVerifiedAt = null;
            order.DeliveryOtpAttempts = 0;
            order.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            var notification = isInitialAssignment
                ? "Đơn hàng đã được phân công cho shipper."
                : "Đơn hàng đã được phân công lại cho shipper.";
            await _notifier.OrderUpdatedAsync(orderId, notification, previousShipperId);
            return Ok(new
            {
                Message = isInitialAssignment
                    ? "Đã phân công đơn hàng cho shipper."
                    : "Đã cập nhật ca điều phối và phân công lại cho shipper."
            });
        }

        private Task<Order?> FindAssignedOrder(int orderId) =>
            _context.Orders.FirstOrDefaultAsync(o =>
                o.OrderId == orderId && o.ShipperId == User.UserId());

        private async Task<ShipperPerformanceResult> BuildPerformanceAsync(
            int shipperId,
            string period,
            DateTime? anchor)
        {
            var (start, end, normalizedPeriod) = ResolvePeriod(period, anchor);
            var orders = await _context.Orders.AsNoTracking()
                .Where(o => o.ShipperId == shipperId)
                .ToListAsync();
            var activeOrders = orders.Count(o => DeliveryStatuses.Active.Contains(o.OrderStatus));
            var completed = orders.Where(o =>
                o.OrderStatus == DeliveryStatuses.Delivered &&
                o.DeliveredAt >= start && o.DeliveredAt < end).ToList();
            var relevant = orders.Where(o =>
            {
                var eventAt = o.DeliveredAt ?? o.UpdatedAt ?? o.OrderDate;
                return eventAt >= start && eventAt < end;
            }).ToList();
            var cancelledDeliveries = relevant.Count(o =>
                o.DeliveryCancelledByShipperId == shipperId &&
                o.DeliveryCancelledAt >= start && o.DeliveryCancelledAt < end);
            var failedAttempts = relevant.Sum(o => o.DeliveryAttemptCount) + cancelledDeliveries;
            var onTimeEligible = completed.Where(o => o.EstimatedDeliveryDate != null).ToList();
            var onTimeCount = onTimeEligible.Count(o =>
                o.DeliveredAt!.Value <= o.EstimatedDeliveryDate!.Value.Date.AddDays(1));
            var averageMinutes = completed
                .Where(o => o.DeliveryAcceptedAt != null && o.DeliveredAt != null &&
                            o.DeliveredAt >= o.DeliveryAcceptedAt)
                .Select(o => (o.DeliveredAt!.Value - o.DeliveryAcceptedAt!.Value).TotalMinutes)
                .DefaultIfEmpty(0)
                .Average();
            var trend = new List<ShipperPerformanceTrendPoint>();
            for (var date = start.Date; date < end.Date; date = date.AddDays(1))
            {
                var next = date.AddDays(1);
                var deliveredOnDate = completed.Where(o => o.DeliveredAt >= date && o.DeliveredAt < next).ToList();
                trend.Add(new ShipperPerformanceTrendPoint
                {
                    Date = date,
                    CompletedOrders = deliveredOnDate.Count,
                    FailedAttempts = relevant.Where(o =>
                    {
                        var eventAt = o.DeliveredAt ?? o.UpdatedAt ?? o.OrderDate;
                        return eventAt >= date && eventAt < next;
                    }).Sum(o => o.DeliveryAttemptCount) + relevant.Count(o =>
                        o.DeliveryCancelledByShipperId == shipperId &&
                        o.DeliveryCancelledAt >= date && o.DeliveryCancelledAt < next),
                    DistanceKm = Math.Round(deliveredOnDate.Sum(o => o.DeliveryDistanceKm ?? 0), 2)
                });
            }
            return new ShipperPerformanceResult
            {
                Period = normalizedPeriod,
                Start = start,
                End = end,
                ActiveOrders = activeOrders,
                CompletedOrders = completed.Count,
                FailedDeliveries = failedAttempts,
                TotalDistanceKm = Math.Round(completed.Sum(o => o.DeliveryDistanceKm ?? 0), 2),
                OnTimeRate = onTimeEligible.Count == 0
                    ? 0
                    : Math.Round(onTimeCount * 100.0 / onTimeEligible.Count, 2),
                RescheduleCount = failedAttempts,
                AverageDeliveryMinutes = Math.Round(averageMinutes, 2),
                Trend = trend
            };
        }

        private static (DateTime Start, DateTime End, string Period) ResolvePeriod(
            string? period,
            DateTime? anchor)
        {
            var point = (anchor ?? DateTime.Today).Date;
            var normalized = period?.Trim().ToLowerInvariant() switch
            {
                "week" => "week",
                "month" => "month",
                _ => "day"
            };
            if (normalized == "week")
            {
                var daysFromMonday = ((int)point.DayOfWeek + 6) % 7;
                var start = point.AddDays(-daysFromMonday);
                return (start, start.AddDays(7), normalized);
            }
            if (normalized == "month")
            {
                var start = new DateTime(point.Year, point.Month, 1);
                return (start, start.AddMonths(1), normalized);
            }
            return (point, point.AddDays(1), normalized);
        }

        private static bool IsCollectOnDelivery(string? method) =>
            method != null &&
            (method.Equals("COD", StringComparison.OrdinalIgnoreCase) ||
             method.Equals("POS", StringComparison.OrdinalIgnoreCase));

        private async Task SetShipperDelivering()
        {
            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == User.UserId());
            if (shipper == null) return;
            shipper.DeliveryShiftStatus = DeliveryShiftStatuses.Delivering;
            var activeCount = await _context.Orders.CountAsync(o =>
                o.ShipperId == shipper.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus));
            shipper.IsAvailableForDelivery = activeCount < shipper.MaxConcurrentDeliveries;
            shipper.AvailabilityUpdatedAt = DateTime.Now;
        }

        private static string HashOtp(int orderId, string otp)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes($"{orderId}:{otp.Trim()}"));
            return Convert.ToHexString(bytes);
        }

        private static string PrependNote(string? notes, string note)
        {
            var entry = $"[{DateTime.Now:dd/MM HH:mm}] {note}";
            return string.IsNullOrWhiteSpace(notes) ? entry : $"{entry}\n{notes}";
        }

        private static string StatusMessage(string status) => status switch
        {
            DeliveryStatuses.Accepted => "Shipper đã chấp nhận đơn giao hàng.",
            DeliveryStatuses.PickedUp => "Shipper đã nhận hàng từ kho.",
            DeliveryStatuses.Shipping => "Đơn hàng đang trên đường giao đến bạn.",
            DeliveryStatuses.Arrived => "Shipper đã đến địa chỉ giao hàng.",
            _ => "Trạng thái giao hàng đã được cập nhật."
        };

        public class ReportIssueRequest
        {
            public string Reason { get; set; } = "Sự cố giao hàng";
            public string? Note { get; set; }
            public string? ProofImage { get; set; }
        }

        public sealed class CancelDeliveryRequest
        {
            public string Reason { get; set; } = string.Empty;
            public string? Note { get; set; }
            public string? ProofImage { get; set; }
        }

        public class RescheduleOrderRequest
        {
            public int? ShipperId { get; set; }
            public DateTime? EstimatedDeliveryDate { get; set; }
            public string? DeliveryTimeSlot { get; set; }
            public string? AdminNote { get; set; }
        }

        public class AvailabilityRequest
        {
            public bool IsAvailable { get; set; }
        }

        public sealed class ShipperProfileRequest
        {
            public string? VehicleType { get; set; }
            public string? VehiclePlate { get; set; }
            public string? ServiceArea { get; set; }
            public bool CanHandleBulkyItems { get; set; }
            public bool CanProvideAssembly { get; set; }
            public int MaxConcurrentDeliveries { get; set; } = 3;
        }

        public sealed class CollectPaymentRequest
        {
            public string? ProofImage { get; set; }
            public string? Note { get; set; }
        }

        public sealed class SubmitReconciliationRequest
        {
            public List<int> PaymentIds { get; set; } = new();
            public string? Note { get; set; }
        }

        public sealed class ReconciliationDecisionRequest
        {
            public string? Note { get; set; }
        }

        private sealed class ShipperPerformanceResult
        {
            public string Period { get; set; } = "day";
            public DateTime Start { get; set; }
            public DateTime End { get; set; }
            public int ActiveOrders { get; set; }
            public int CompletedOrders { get; set; }
            public int FailedDeliveries { get; set; }
            public double TotalDistanceKm { get; set; }
            public double OnTimeRate { get; set; }
            public int RescheduleCount { get; set; }
            public double AverageDeliveryMinutes { get; set; }
            public List<ShipperPerformanceTrendPoint> Trend { get; set; } = new();
        }

        private sealed class ShipperPerformanceTrendPoint
        {
            public DateTime Date { get; set; }
            public int CompletedOrders { get; set; }
            public int FailedAttempts { get; set; }
            public double DistanceKm { get; set; }
        }

        public sealed class ShiftRequest
        {
            public string? Status { get; set; }
            public DateTime? BreakUntil { get; set; }
        }

        public sealed class RejectAssignmentRequest
        {
            public string Reason { get; set; } = string.Empty;
        }

        public sealed class DeliveryStatusRequest
        {
            public string Status { get; set; } = string.Empty;
        }

        public sealed class VerifyOtpRequest
        {
            public string? Otp { get; set; }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.Backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using furniture_BE.Extensions;
using System.Data;
using furniture_BE.Services;

namespace furniture_BE.Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly RecommendationService _recommendations;
        private readonly DeliveryRealtimeNotifier _deliveryNotifier;

        public OrdersController(
            AppDbContext context,
            IConfiguration configuration,
            RecommendationService recommendations,
            DeliveryRealtimeNotifier deliveryNotifier)
        {
            _context = context;
            _configuration = configuration;
            _recommendations = recommendations;
            _deliveryNotifier = deliveryNotifier;
        }

        // POST: api/orders
        [HttpPost]
        public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
        {
            if (request.Items == null || !request.Items.Any() || request.Items.Any(i => i.Quantity <= 0))
            {
                return BadRequest(new { Message = "Giỏ hàng rỗng." });
            }

            var currentUserId = User.UserId();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == currentUserId);
            if (user == null)
            {
                return BadRequest(new { Message = "Không tìm thấy thông tin tài khoản." });
            }

            if (string.IsNullOrWhiteSpace(request.ShippingAddress) || string.IsNullOrWhiteSpace(request.RecipientName) || string.IsNullOrWhiteSpace(request.RecipientPhone))
                return BadRequest(new { Message = "Vui lòng nhập đầy đủ người nhận, số điện thoại và địa chỉ." });

            using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
            try
            {
                decimal totalAmount = 0;
                var orderDetails = new List<OrderDetail>();
                var orderItemsHtml = new StringBuilder();

                foreach (var item in request.Items)
                {
                    var variant = await _context.ProductVariants
                        .Include(v => v.Product)
                        .FirstOrDefaultAsync(v => v.VariantId == item.ProductVariantId);

                    if (variant == null)
                    {
                        return BadRequest(new { Message = $"Không tìm thấy biến thể sản phẩm ID {item.ProductVariantId}" });
                    }

                    if (variant.StockQuantity < item.Quantity)
                    {
                        return BadRequest(new { Message = $"Sản phẩm {variant.Product?.ProductName} ({variant.Color} - {variant.Size}) không đủ hàng tồn kho. Còn lại: {variant.StockQuantity}." });
                    }

                    // Deduct stock quantity
                    variant.StockQuantity -= item.Quantity;

                    // Server chốt giá tại lúc mua và lưu vào OrderDetail.
                    decimal itemPrice = variant.Product!.GetEffectivePrice(
                        variant.AdditionalPrice,
                        DateTime.UtcNow);
                    totalAmount += itemPrice * item.Quantity;

                    orderItemsHtml.Append($"<tr>" +
                        $"<td style='padding: 10px; border-bottom: 1px solid #eee;'>{variant.Product?.ProductName} ({variant.Color} - {variant.Size})</td>" +
                        $"<td style='padding: 10px; border-bottom: 1px solid #eee; text-align: center;'>{item.Quantity}</td>" +
                        $"<td style='padding: 10px; border-bottom: 1px solid #eee; text-align: right;'>{itemPrice:N0} VNĐ</td>" +
                        $"<td style='padding: 10px; border-bottom: 1px solid #eee; text-align: right; font-weight: bold;'>{(itemPrice * item.Quantity):N0} VNĐ</td>" +
                        $"</tr>");

                    orderDetails.Add(new OrderDetail
                    {
                        VariantId = variant.VariantId,
                        Quantity = item.Quantity,
                        UnitPrice = itemPrice
                    });
                }

                var subtotal = totalAmount;
                decimal discountAmount = 0;
                string? appliedVoucherCode = null;
                if (!string.IsNullOrWhiteSpace(request.VoucherCode))
                {
                    var code = request.VoucherCode.Trim().ToUpper();
                    var voucher = await _context.Vouchers.FirstOrDefaultAsync(v => v.VoucherCode.ToUpper() == code);
                    var now = DateTime.Now;
                    if (voucher == null || !voucher.IsActive || voucher.StartDate > now || voucher.EndDate < now ||
                        voucher.UsedCount >= voucher.UsageLimit || subtotal < voucher.MinOrderAmount)
                        return BadRequest(new { Message = "Voucher không hợp lệ, đã hết lượt hoặc chưa đạt giá trị đơn tối thiểu." });

                    discountAmount = voucher.DiscountType == 1
                        ? subtotal * voucher.DiscountValue / 100m
                        : voucher.DiscountValue;
                    if (voucher.MaxDiscountAmount.HasValue)
                        discountAmount = Math.Min(discountAmount, voucher.MaxDiscountAmount.Value);
                    discountAmount = Math.Min(discountAmount, subtotal);
                    voucher.UsedCount += 1;
                    voucher.UpdatedAt = now;
                    appliedVoucherCode = voucher.VoucherCode;
                }

                var distanceKm = Math.Max(0, request.DeliveryDistanceKm ?? 0);
                decimal shippingFee = 50000m;
                if (distanceKm > 5) shippingFee += (decimal)Math.Ceiling(distanceKm - 5) * 8000m;
                decimal assemblyFee = request.IncludesAssembly ? 100000m : 0m;
                totalAmount = subtotal - discountAmount + shippingFee + assemblyFee;
                string paymentMethod = (request.PaymentMethod ?? "VNPAY").Trim().ToUpperInvariant();
                if (paymentMethod != "VNPAY" && paymentMethod != "POS" && paymentMethod != "BANK")
                {
                    return BadRequest(new { Message = "Phương thức thanh toán không được hỗ trợ." });
                }

                bool isPos = paymentMethod.Equals("POS", StringComparison.OrdinalIgnoreCase);
                bool isVnPay = paymentMethod.Equals("VNPAY", StringComparison.OrdinalIgnoreCase);

                var order = new Order
                {
                    UserId = currentUserId,
                    OrderDate = DateTime.Now,
                    ShippingAddress = request.ShippingAddress,
                    TotalAmount = totalAmount,
                    ShippingFee = shippingFee,
                    AssemblyFee = assemblyFee,
                    DeliveryDistanceKm = distanceKm,
                    DeliveryTimeSlot = request.DeliveryTimeSlot,
                    EstimatedDeliveryDate = request.EstimatedDeliveryDate,
                    IncludesAssembly = request.IncludesAssembly,
                    VoucherCode = appliedVoucherCode,
                    RecipientName = request.RecipientName.Trim(),
                    RecipientPhone = request.RecipientPhone.Trim(),
                    RecipientEmail = string.IsNullOrWhiteSpace(request.RecipientEmail) ? user.Email : request.RecipientEmail.Trim(),
                    CustomerNote = request.CustomerNote?.Trim(),
                    OrderStatus = isPos ? "Processing" : "Pending",
                    OrderDetails = orderDetails
                };

                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                order.OrderCode = $"DH-{order.OrderDate:yyyyMMdd}-{order.OrderId:D6}";
                await _context.SaveChangesAsync();

                var payment = new Payment
                {
                    OrderId = order.OrderId,
                    PaymentMethod = paymentMethod,
                    Amount = totalAmount,
                    PaymentDate = DateTime.Now,
                    TransactionId = "",
                    PaymentStatus = "Pending"
                };

                _context.Payments.Add(payment);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                // Gửi email xác nhận phiếu đặt hàng trong tiến trình nền
                string toEmail = order.RecipientEmail ?? user.Email;
                string custName = order.RecipientName;
                string orderCodeStr = order.OrderCode;
                DateTime dt = order.OrderDate;
                string addr = order.ShippingAddress;
                string itemsStr = orderItemsHtml.ToString();
                decimal total = totalAmount;
                decimal disc = discountAmount;
                decimal sFee = shippingFee;
                decimal aFee = assemblyFee;

                _ = Task.Run(() => SendOrderConfirmationEmail(toEmail, custName, orderCodeStr, dt, addr, paymentMethod, itemsStr, total, disc, sFee, aFee));

                string paymentUrl = "";
                if (isVnPay)
                {
                    // Create VNPay payment link
                    var vnpay = new VnPayLibrary();
                    vnpay.AddRequestData("vnp_Version", "2.1.0");
                    vnpay.AddRequestData("vnp_Command", "pay");
                    vnpay.AddRequestData("vnp_TmnCode", _configuration["VnPay:TmnCode"] ?? "");
                    vnpay.AddRequestData("vnp_Amount", ((long)(totalAmount * 100)).ToString());
                    vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
                    vnpay.AddRequestData("vnp_ExpireDate", DateTime.Now.AddMinutes(15).ToString("yyyyMMddHHmmss"));
                    vnpay.AddRequestData("vnp_CurrCode", "VND");
                    vnpay.AddRequestData("vnp_IpAddr", HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1");
                    vnpay.AddRequestData("vnp_Locale", "vn");
                    vnpay.AddRequestData("vnp_OrderInfo", $"Thanh toan don hang {order.OrderId}");
                    vnpay.AddRequestData("vnp_OrderType", "other");
                    vnpay.AddRequestData("vnp_ReturnUrl", _configuration["VnPay:ReturnUrl"] ?? "");
                    vnpay.AddRequestData("vnp_TxnRef", order.OrderId.ToString());

                    paymentUrl = vnpay.CreateRequestUrl(_configuration["VnPay:Url"] ?? "", _configuration["VnPay:HashSecret"] ?? "");
                }

                return Ok(new { OrderId = order.OrderId, PaymentUrl = paymentUrl });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // GET: api/orders/vnpay-return
        [HttpGet("vnpay-return")]
        [AllowAnonymous]
        public async Task<IActionResult> VnPayReturn()
        {
            var vnpay = new VnPayLibrary();
            foreach (var key in Request.Query.Keys)
            {
                var value = Request.Query[key].ToString();
                if (!string.IsNullOrEmpty(key) && key.StartsWith("vnp_"))
                {
                    vnpay.AddResponseData(key, value);
                }
            }

            string inputHash = Request.Query["vnp_SecureHash"].ToString();
            bool isSignatureValid = vnpay.ValidateSignature(inputHash, _configuration["VnPay:HashSecret"] ?? "");

            if (!isSignatureValid)
            {
                return BadRequest("Chữ ký giao dịch không hợp lệ.");
            }

            int orderId = int.Parse(vnpay.GetResponseData("vnp_TxnRef"));
            string responseCode = vnpay.GetResponseData("vnp_ResponseCode");
            string transactionStatus = vnpay.GetResponseData("vnp_TransactionStatus");
            string transactionNo = vnpay.GetResponseData("vnp_TransactionNo");
            bool amountValid = long.TryParse(vnpay.GetResponseData("vnp_Amount"), out var paidAmount);

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == orderId);

            if (order == null || payment == null)
            {
                return NotFound("Không tìm thấy đơn hàng hoặc giao dịch thanh toán.");
            }

            string status = "failed";

            if (!payment.PaymentMethod.Equals("VNPAY", StringComparison.OrdinalIgnoreCase) ||
                !amountValid || paidAmount != (long)(payment.Amount * 100m))
                return BadRequest("Thông tin giao dịch không khớp đơn hàng.");

            if (payment.PaymentStatus == "Success")
            {
                status = "success";
            }
            else if (responseCode == "00" && transactionStatus == "00")
            {
                status = "success";
                payment.PaymentStatus = "Success";
                payment.TransactionId = transactionNo;
                payment.UpdatedAt = DateTime.Now;

                order.OrderStatus = "Pending"; // Sẽ chờ xác nhận
                order.UpdatedAt = DateTime.Now;
            }
            else if (payment.PaymentStatus == "Pending")
            {
                payment.PaymentStatus = "Failed";
                payment.TransactionId = transactionNo;
                payment.UpdatedAt = DateTime.Now;

                order.OrderStatus = "Cancelled"; // Thanh toán thất bại -> tự hủy
                order.UpdatedAt = DateTime.Now;

                // Restore stock
                var details = await _context.OrderDetails.Where(d => d.OrderId == orderId).ToListAsync();
                foreach (var det in details)
                {
                    var variant = await _context.ProductVariants.FirstOrDefaultAsync(v => v.VariantId == det.VariantId);
                    if (variant != null)
                    {
                        variant.StockQuantity += det.Quantity;
                    }
                }
                await RestoreVoucherUsage(order.VoucherCode);
            }

            await _context.SaveChangesAsync();

            var frontendUrl = (_configuration["FrontendUrl"] ?? "http://localhost:8085").TrimEnd('/');
            return Redirect($"{frontendUrl}/#/checkout?status={status}&orderId={orderId}");
        }

        [HttpGet("vnpay-ipn")]
        [AllowAnonymous]
        public async Task<IActionResult> VnPayIpn()
        {
            var result = await VnPayReturn();
            return result switch
            {
                BadRequestObjectResult => Ok(new { RspCode = "97", Message = "Invalid signature or transaction" }),
                NotFoundObjectResult => Ok(new { RspCode = "01", Message = "Order not found" }),
                _ => Ok(new { RspCode = "00", Message = "Confirm success" })
            };
        }

        [HttpGet("{orderId:int}/payment-status")]
        public async Task<IActionResult> GetPaymentStatus(int orderId)
        {
            var order = await _context.Orders.Include(o => o.Payments).FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null) return NotFound(new { Message = "Không tìm thấy đơn hàng." });
            if (order.UserId != User.UserId() && !User.IsInRole("Admin")) return Forbid();
            var payment = order.Payments.OrderByDescending(p => p.PaymentId).FirstOrDefault();
            return Ok(new { order.OrderId, order.OrderCode, order.OrderStatus, PaymentStatus = payment?.PaymentStatus ?? "Pending", Amount = payment?.Amount ?? order.TotalAmount });
        }

        // GET: api/orders/my-orders/{userId}
        [HttpGet("my-orders/{userId}")]
        public async Task<IActionResult> GetMyOrders(int userId)
        {
            if (User.UserId() != userId && !User.IsInRole("Admin")) return Forbid();
            var orders = await _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(d => d.ProductVariant)
                        .ThenInclude(v => v.Product)
                .Include(o => o.OrderDetails)
                    .ThenInclude(d => d.ProductVariant)
                        .ThenInclude(v => v.ProductImages)
                .Include(o => o.Payments)
                .Include(o => o.Shipper)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new {
                    o.OrderId,
                    o.OrderCode,
                    o.OrderDate,
                    o.ShippingAddress,
                    o.TotalAmount,
                    o.OrderStatus,
                    o.ShippingFee,
                    o.AssemblyFee,
                    o.IncludesAssembly,
                    o.DeliveryDistanceKm,
                    o.EstimatedDeliveryDate,
                    o.DeliveryTimeSlot,
                    o.ShipperId,
                    ShipperName = o.Shipper != null ? o.Shipper.FullName : "Chưa phân công",
                    o.DeliveryProofImage,
                    o.DeliveryNotes,
                    o.DeliveryAttemptCount,
                    OrderDetails = o.OrderDetails.Select(d => new {
                        d.OrderDetailId,
                        ProductVariantId = d.VariantId,
                        ProductId = d.ProductVariant != null ? d.ProductVariant.ProductId : 0,
                        d.Quantity,
                        Price = d.UnitPrice,
                        ProductName = d.ProductVariant != null && d.ProductVariant.Product != null ? d.ProductVariant.Product.ProductName : "Sản phẩm",
                        Color = d.ProductVariant != null ? d.ProductVariant.Color : "",
                        Size = d.ProductVariant != null ? d.ProductVariant.Size : "",
                        ImageUrl = d.ProductVariant != null && d.ProductVariant.ProductImages.Any()
                            ? "/uploads/products/by-id/" + d.ProductVariant.ProductImages.First().ImageId
                            : "",
                        HasReviewed = d.ProductVariant != null && _context.Reviews.Any(r =>
                            r.UserId == o.UserId && r.ProductId == d.ProductVariant.ProductId),
                        CanReview = o.OrderStatus == "Delivered"
                            && d.ProductVariant != null
                            && !_context.Reviews.Any(r =>
                                r.UserId == o.UserId && r.ProductId == d.ProductVariant.ProductId)
                    }),
                    PaymentMethod = o.Payments.Any() ? o.Payments.First().PaymentMethod : "Chưa xác định",
                    PaymentStatus = o.Payments.Any() ? o.Payments.First().PaymentStatus : "Chưa thanh toán",
                    PaymentAmount = o.Payments.OrderByDescending(p => p.PaymentId)
                        .Select(p => (decimal?)p.Amount).FirstOrDefault(),
                    PaymentCollectedAt = o.Payments.Any() ? o.Payments.First().CollectedAt : null,
                    PaymentCollectionProofImage = o.Payments.Any() ? o.Payments.First().CollectionProofImage : null,
                    PaymentHandoverStatus = o.Payments.Any() ? o.Payments.First().HandoverStatus : "NotRequired",
                    o.DeliveryCancelledAt,
                    o.DeliveryCancelledByShipperId,
                    o.DeliveryCancellationReason,
                    o.DeliveryCancellationNote,
                    o.DeliveryCancellationProofImage
                })
                .ToListAsync();

            return Ok(orders);
        }

        // GET: api/admin/orders (Admin list all)
        [HttpGet("admin/all")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminAllOrders()
        {
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.Shipper)
                .Include(o => o.OrderDetails)
                    .ThenInclude(d => d.ProductVariant)
                        .ThenInclude(v => v.Product)
                .Include(o => o.Payments)
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new {
                    o.OrderId,
                    o.OrderCode,
                    o.OrderDate,
                    o.ShippingAddress,
                    o.TotalAmount,
                    o.OrderStatus,
                    o.ShippingFee,
                    o.AssemblyFee,
                    o.IncludesAssembly,
                    o.DeliveryDistanceKm,
                    o.EstimatedDeliveryDate,
                    o.DeliveryTimeSlot,
                    o.ShipperId,
                    ShipperName = o.Shipper != null ? o.Shipper.FullName : "Chưa phân công",
                    o.DeliveryProofImage,
                    o.DeliveryNotes,
                    o.DeliveryAttemptCount,
                    UserFullName = o.RecipientName != "" ? o.RecipientName : (o.User != null ? o.User.FullName : "Khách hàng"),
                    UserEmail = o.RecipientEmail ?? (o.User != null ? o.User.Email : ""),
                    UserPhone = o.RecipientPhone != "" ? o.RecipientPhone : (o.User != null ? o.User.Phone : ""),
                    o.CustomerNote,
                    OrderDetails = o.OrderDetails.Select(d => new {
                        d.OrderDetailId,
                        ProductVariantId = d.VariantId,
                        d.Quantity,
                        Price = d.UnitPrice,
                        ProductName = d.ProductVariant != null && d.ProductVariant.Product != null ? d.ProductVariant.Product.ProductName : "Sản phẩm",
                        Color = d.ProductVariant != null ? d.ProductVariant.Color : "",
                        Size = d.ProductVariant != null ? d.ProductVariant.Size : "",
                    }),
                    PaymentMethod = o.Payments.Any() ? o.Payments.First().PaymentMethod : "Chưa xác định",
                    PaymentStatus = o.Payments.Any() ? o.Payments.First().PaymentStatus : "Chưa thanh toán",
                    TransactionId = o.Payments.Any() ? o.Payments.First().TransactionId : ""
                })
                .ToListAsync();

            return Ok(orders);
        }

        // PUT: api/orders/admin/{orderId}/status
        [HttpPut("admin/{orderId}/status")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateOrderStatus(int orderId, [FromBody] UpdateStatusRequest request)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return NotFound(new { Message = "Không tìm thấy đơn hàng." });
            }

            string oldStatus = order.OrderStatus;
            string requestedStatus = request.Status?.Trim() ?? string.Empty;
            if (requestedStatus.Equals("Delivered", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { Message = "Chỉ shipper phụ trách mới được xác nhận đơn hàng đã giao." });
            }

            string? newStatus = requestedStatus.ToLowerInvariant() switch
            {
                "pending" => "Pending",
                "processing" => "Processing",
                "cancelled" => "Cancelled",
                _ => null
            };
            if (newStatus == null)
                return BadRequest(new { Message = "Trạng thái đơn hàng không hợp lệ." });

            if (oldStatus.Equals("Delivered", StringComparison.OrdinalIgnoreCase)
                || oldStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
            {
                return BadRequest(new { Message = "Không thể thay đổi trạng thái của đơn hàng đã hoàn tất hoặc đã hủy." });
            }

            if (oldStatus.Equals("Shipping", StringComparison.OrdinalIgnoreCase)
                || oldStatus.Equals("Rescheduled", StringComparison.OrdinalIgnoreCase)
                || order.ShipperId.HasValue)
            {
                return BadRequest(new
                {
                    Message = "Đơn hàng đã được bàn giao cho shipper. Admin không thể thay đổi trạng thái giao hàng."
                });
            }

            var validTransition =
                (oldStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase)
                    && (newStatus.Equals("Processing", StringComparison.OrdinalIgnoreCase)
                        || newStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase)))
                || (oldStatus.Equals("Processing", StringComparison.OrdinalIgnoreCase)
                    && newStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase));
            if (!validTransition)
                return BadRequest(new { Message = "Không thể chuyển sang trạng thái này từ trạng thái hiện tại." });

            order.OrderStatus = newStatus;
            order.UpdatedAt = DateTime.Now;

            // If switching to Cancelled, restore stock
            if (newStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) && !oldStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
            {
                foreach (var det in order.OrderDetails)
                {
                    var variant = await _context.ProductVariants.FirstOrDefaultAsync(v => v.VariantId == det.VariantId);
                    if (variant != null)
                    {
                        variant.StockQuantity += det.Quantity;
                    }
                }
                await RestoreVoucherUsage(order.VoucherCode);
            }

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Cập nhật trạng thái đơn hàng thành công." });
        }

        // GET: api/orders/shippers (Get all shippers for Admin dropdown)
        [HttpGet("shippers")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetShippers()
        {
            var shippers = await _context.Users
                .Where(u => u.RoleId == 3)
                .Select(u => new {
                    u.UserId,
                    u.FullName,
                    u.Email,
                    u.Phone,
                    u.IsAvailableForDelivery,
                    u.AvailabilityUpdatedAt,
                    u.DeliveryShiftStatus,
                    u.DeliveryVehicleType,
                    u.DeliveryVehiclePlate,
                    u.MaxConcurrentDeliveries
                })
                .ToListAsync();

            return Ok(shippers);
        }

        // POST: api/orders/calculate-shipping
        [HttpPost("calculate-shipping")]
        public IActionResult CalculateShipping([FromBody] CalculateShippingRequest request)
        {
            decimal assemblyFee = request.IncludesAssembly ? 100000m : 0m;
            decimal shippingFee = 50000m;
            if (request.DistanceKm > 5.0)
            {
                shippingFee += (decimal)Math.Ceiling(request.DistanceKm - 5.0) * 8000m;
            }

            return Ok(new {
                ShippingFee = shippingFee,
                AssemblyFee = assemblyFee,
                TotalDeliveryCost = shippingFee + assemblyFee
            });
        }

        // POST: api/orders/admin/{orderId}/assign-shipper
        [HttpPost("admin/{orderId}/assign-shipper")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AssignShipper(int orderId, [FromBody] AssignShipperRequest request)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
                return NotFound(new { Message = "Không tìm thấy đơn hàng." });
            if (order.OrderStatus.Equals("Delivered", StringComparison.OrdinalIgnoreCase)
                || order.OrderStatus.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
                return BadRequest(new { Message = "Không thể phân công shipper cho đơn hàng đã hoàn tất hoặc đã hủy." });
            if (order.ShipperId.HasValue && order.OrderStatus != DeliveryStatuses.Assigned &&
                DeliveryStatuses.Active.Contains(order.OrderStatus))
                return BadRequest(new { Message = "Shipper đã tiếp nhận đơn. Chỉ có thể điều phối lại sau khi shipper báo sự cố." });

            var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == request.ShipperId && u.RoleId == 3);
            if (shipper == null)
                return BadRequest(new { Message = "Tài khoản Shipper không hợp lệ hoặc không tồn tại." });
            if (!shipper.IsAvailableForDelivery && shipper.DeliveryShiftStatus != DeliveryShiftStatuses.Delivering)
                return BadRequest(new { Message = "Shipper đang ở trạng thái không sẵn sàng." });
            if (order.IncludesAssembly && !shipper.CanProvideAssembly)
                return BadRequest(new { Message = "Shipper này chưa được đánh dấu có khả năng lắp đặt." });
            var activeCount = await _context.Orders.CountAsync(o =>
                o.ShipperId == shipper.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus));
            if (activeCount >= shipper.MaxConcurrentDeliveries)
                return BadRequest(new { Message = "Shipper đã đạt số đơn tối đa có thể xử lý." });

            var previousShipperId = order.ShipperId;
            order.ShipperId = request.ShipperId;
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
            await _deliveryNotifier.OrderUpdatedAsync(orderId, $"Đơn hàng đã được phân công cho {shipper.FullName}.", previousShipperId);
            return Ok(new { Message = $"Đã phân công đơn hàng cho Shipper {shipper.FullName}." });
        }

        // GET: api/orders/shipper/{shipperId}
        [HttpGet("shipper/{shipperId}")]
        [Authorize(Roles = "Shipper,Admin")]
        public async Task<IActionResult> GetShipperOrders(int shipperId)
        {
            if (User.UserId() != shipperId && !User.IsInRole("Admin")) return Forbid();
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderDetails)
                    .ThenInclude(d => d.ProductVariant)
                        .ThenInclude(v => v.Product)
                .Include(o => o.Payments)
                .Where(o => o.ShipperId == shipperId)
                .OrderByDescending(o => o.OrderDate)
                .Select(o => new {
                    o.OrderId,
                    o.OrderCode,
                    o.OrderDate,
                    o.ShippingAddress,
                    o.TotalAmount,
                    o.OrderStatus,
                    o.ShippingFee,
                    o.AssemblyFee,
                    o.IncludesAssembly,
                    o.DeliveryDistanceKm,
                    o.EstimatedDeliveryDate,
                    o.DeliveryTimeSlot,
                    o.ShipperId,
                    o.DeliveryProofImage,
                    o.DeliveryNotes,
                    o.DeliveryAttemptCount,
                    o.DeliveryAssignedAt,
                    o.DeliveryAssignmentExpiresAt,
                    o.DeliveryAcceptedAt,
                    o.DeliveryPickedUpAt,
                    o.DeliveryArrivedAt,
                    o.DeliveredAt,
                    o.DeliveryRecipientName,
                    o.DeliveryIssueProofImage,
                    OtpVerified = o.DeliveryOtpVerifiedAt != null,
                    UserFullName = o.RecipientName != "" ? o.RecipientName : (o.User != null ? o.User.FullName : "Khách hàng"),
                    UserPhone = o.RecipientPhone != "" ? o.RecipientPhone : (o.User != null ? o.User.Phone : ""),
                    o.CustomerNote,
                    OrderDetails = o.OrderDetails.Select(d => new {
                        d.OrderDetailId,
                        ProductVariantId = d.VariantId,
                        d.Quantity,
                        Price = d.UnitPrice,
                        ProductName = d.ProductVariant != null && d.ProductVariant.Product != null ? d.ProductVariant.Product.ProductName : "Sản phẩm",
                        Color = d.ProductVariant != null ? d.ProductVariant.Color : "",
                        Size = d.ProductVariant != null ? d.ProductVariant.Size : "",
                    }),
                    PaymentMethod = o.Payments.Any() ? o.Payments.First().PaymentMethod : "Chưa xác định",
                    PaymentStatus = o.Payments.Any() ? o.Payments.First().PaymentStatus : "Chưa thanh toán",
                    PaymentAmount = o.Payments.OrderByDescending(p => p.PaymentId)
                        .Select(p => (decimal?)p.Amount).FirstOrDefault(),
                    PaymentCollectedAt = o.Payments.Any() ? o.Payments.First().CollectedAt : null,
                    PaymentCollectionProofImage = o.Payments.Any() ? o.Payments.First().CollectionProofImage : null,
                    PaymentHandoverStatus = o.Payments.Any() ? o.Payments.First().HandoverStatus : "NotRequired",
                    o.DeliveryCancelledAt,
                    o.DeliveryCancelledByShipperId,
                    o.DeliveryCancellationReason,
                    o.DeliveryCancellationNote,
                    o.DeliveryCancellationProofImage
                })
                .ToListAsync();

            return Ok(orders);
        }

        // PUT: api/orders/shipper/{orderId}/complete
        [HttpPut("shipper/{orderId}/complete")]
        [Authorize(Roles = "Shipper")]
        public async Task<IActionResult> CompleteDelivery(int orderId, [FromBody] CompleteDeliveryRequest request)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId);
            if (order == null)
                return NotFound(new { Message = "Không tìm thấy đơn hàng." });

            if (order.ShipperId != User.UserId()) return Forbid();
            if (order.OrderStatus != DeliveryStatuses.Arrived)
                return BadRequest(new { Message = "Shipper phải xác nhận đã đến nơi trước khi hoàn tất." });
            if (order.DeliveryOtpVerifiedAt == null)
                return BadRequest(new { Message = "Vui lòng xác minh OTP của người nhận." });
            if (string.IsNullOrWhiteSpace(request.DeliveryProofImage))
                return BadRequest(new { Message = "Bắt buộc tải ảnh bằng chứng giao hàng." });
            if (string.IsNullOrWhiteSpace(request.RecipientName))
                return BadRequest(new { Message = "Vui lòng nhập tên người thực tế nhận hàng." });

            order.OrderStatus = DeliveryStatuses.Delivered;
            order.DeliveryProofImage = request.DeliveryProofImage.Trim();
            order.DeliveryRecipientName = request.RecipientName.Trim();
            order.DeliveredAt = DateTime.Now;
            order.UpdatedAt = DateTime.Now;

            var payment = await _context.Payments.FirstOrDefaultAsync(p => p.OrderId == orderId);
            if (payment != null &&
                (payment.PaymentMethod.Equals("COD", StringComparison.OrdinalIgnoreCase) ||
                 payment.PaymentMethod.Equals("POS", StringComparison.OrdinalIgnoreCase)) &&
                payment.CollectedAt == null)
            {
                return BadRequest(new
                {
                    Message = "Shipper phải xác nhận đã thu đúng số tiền COD/POS trước khi hoàn tất giao hàng."
                });
            }

            await _context.SaveChangesAsync();
            var shipperHasOtherActiveOrders = await _context.Orders.AnyAsync(o =>
                o.ShipperId == order.ShipperId && o.OrderId != order.OrderId &&
                DeliveryStatuses.Active.Contains(o.OrderStatus));
            if (order.ShipperId.HasValue)
            {
                var shipper = await _context.Users.FirstOrDefaultAsync(u => u.UserId == order.ShipperId.Value);
                if (shipper != null && shipper.DeliveryShiftStatus == DeliveryShiftStatuses.Delivering)
                {
                    if (!shipperHasOtherActiveOrders)
                        shipper.DeliveryShiftStatus = DeliveryShiftStatuses.Available;
                    var remainingActiveCount = await _context.Orders.CountAsync(o =>
                        o.ShipperId == shipper.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus));
                    shipper.IsAvailableForDelivery = remainingActiveCount < shipper.MaxConcurrentDeliveries;
                    await _context.SaveChangesAsync();
                }
            }
            await _deliveryNotifier.OrderUpdatedAsync(orderId, "Đơn hàng đã được giao thành công.");
            try { await _recommendations.RebuildAsync(isAutomatic: true); }
            catch (Exception ex) { Console.WriteLine($"[RECOMMENDATIONS] {ex.Message}"); }
            return Ok(new { Message = "Xác nhận giao hàng & lắp đặt thành công!" });
        }

        private async Task RestoreVoucherUsage(string? voucherCode)
        {
            if (string.IsNullOrWhiteSpace(voucherCode)) return;
            var code = voucherCode.ToUpper();
            var voucher = await _context.Vouchers.FirstOrDefaultAsync(v => v.VoucherCode.ToUpper() == code);
            if (voucher != null && voucher.UsedCount > 0) voucher.UsedCount--;
        }

        private void SendOrderConfirmationEmail(string toEmail, string customerName, string orderCode, DateTime orderDate, string shippingAddress, string paymentMethod, string itemsHtml, decimal totalAmount, decimal discount, decimal shippingFee, decimal assemblyFee)
        {
            try
            {
                var smtpHost = _configuration["SmtpSettings:Host"];
                var smtpPort = int.Parse(_configuration["SmtpSettings:Port"] ?? "587");
                var senderEmail = _configuration["SmtpSettings:SenderEmail"];
                var senderPass = _configuration["SmtpSettings:SenderPassword"];
                var senderName = _configuration["SmtpSettings:SenderName"] ?? "My Furniture Store";

                if (string.IsNullOrEmpty(smtpHost) || string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderPass))
                {
                    Console.WriteLine("[SMTP ORDER] Cấu hình SMTP trống, bỏ qua gửi email xác nhận đơn hàng.");
                    return;
                }

                using var client = new SmtpClient(smtpHost, smtpPort)
                {
                    Credentials = new NetworkCredential(senderEmail, senderPass),
                    EnableSsl = _configuration.GetValue<bool>("SmtpSettings:EnableSsl", true)
                };

                string methodText = paymentMethod.ToUpperInvariant() switch
                {
                    "POS" => "Thanh toán quẹt thẻ khi nhận hàng (POS)",
                    "BANK" => "Chuyển khoản ngân hàng",
                    _ => "Thanh toán trực tuyến VNPay"
                };
                string statusText = paymentMethod.ToUpperInvariant() switch
                {
                    "POS" => "Đang xử lý (thanh toán khi giao hàng)",
                    "BANK" => "Chờ xác nhận chuyển khoản",
                    _ => "Chờ thanh toán VNPay"
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(senderEmail, senderName),
                    Subject = $"[My Furniture Store] Phiếu Xác Nhận Đặt Hàng #{orderCode}",
                    IsBodyHtml = true,
                    Body = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 650px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; background-color: #ffffff;'>
                        <div style='background-color: #1a1a1a; color: #ffffff; padding: 25px; text-align: center;'>
                            <h1 style='margin: 0; font-size: 26px; letter-spacing: 3px; font-weight: bold;'>MY FURNITURE STORE</h1>
                            <p style='margin: 8px 0 0; font-size: 15px; color: #d4af37; font-weight: 600;'>PHIẾU XÁC NHẬN ĐẶT HÀNG / INVOICE</p>
                        </div>
                        <div style='padding: 30px;'>
                            <h3 style='color: #2d2d2d; margin-top: 0; font-size: 20px;'>Xin chào {customerName},</h3>
                            <p style='color: #555555; line-height: 1.6; font-size: 15px;'>Cảm ơn bạn đã đặt hàng tại <b>My Furniture Store</b>! Chúng tôi trân trọng gửi đến bạn chi tiết đơn hàng vừa được tiếp nhận thành công:</p>
                            
                            <div style='background-color: #fcfcfc; border: 1px solid #eaeaea; border-left: 5px solid #d4af37; padding: 18px; margin: 25px 0; border-radius: 6px;'>
                                <table style='width: 100%; font-size: 14px; border-collapse: collapse;'>
                                    <tr><td style='padding: 4px 0; color: #777; width: 150px;'>Mã đơn hàng:</td><td style='padding: 4px 0; font-weight: bold; color: #d9534f; font-size: 16px;'>{orderCode}</td></tr>
                                    <tr><td style='padding: 4px 0; color: #777;'>Ngày đặt hàng:</td><td style='padding: 4px 0; font-weight: 500;'>{orderDate:dd/MM/yyyy HH:mm}</td></tr>
                                    <tr><td style='padding: 4px 0; color: #777;'>Thanh toán:</td><td style='padding: 4px 0; font-weight: 500;'>{methodText}</td></tr>
                                    <tr><td style='padding: 4px 0; color: #777;'>Trạng thái:</td><td style='padding: 4px 0; font-weight: bold; color: #28a745;'>{statusText}</td></tr>
                                    <tr><td style='padding: 4px 0; color: #777; vertical-align: top;'>Địa chỉ nhận:</td><td style='padding: 4px 0; font-weight: 500;'>{shippingAddress}</td></tr>
                                </table>
                            </div>

                            <h4 style='color: #2d2d2d; border-bottom: 2px solid #2d2d2d; padding-bottom: 10px; margin-top: 30px; font-size: 16px; letter-spacing: 1px;'>CHI TIẾT ĐƠN HÀNG</h4>
                            <table style='width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px;'>
                                <thead>
                                    <tr style='background-color: #f7f7f7; text-align: left; color: #555;'>
                                        <th style='padding: 12px 10px; border-bottom: 2px solid #e0e0e0;'>Sản phẩm</th>
                                        <th style='padding: 12px 10px; border-bottom: 2px solid #e0e0e0; text-align: center;'>SL</th>
                                        <th style='padding: 12px 10px; border-bottom: 2px solid #e0e0e0; text-align: right;'>Đơn giá</th>
                                        <th style='padding: 12px 10px; border-bottom: 2px solid #e0e0e0; text-align: right;'>Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {itemsHtml}
                                </tbody>
                            </table>

                            <div style='margin-top: 25px; padding-top: 15px; text-align: right; font-size: 14px;'>
                                <p style='margin: 6px 0; color: #555;'>Phí dịch vụ lắp đặt: <b style='color: #2d2d2d;'>+{assemblyFee:N0} VNĐ</b></p>
                                <p style='margin: 6px 0; color: #555;'>Phí vận chuyển: <b style='color: #2d2d2d;'>+{shippingFee:N0} VNĐ</b></p>
                                {(discount > 0 ? $"<p style='margin: 6px 0; color: #28a745;'>Khuyến mãi voucher: <b>-{discount:N0} VNĐ</b></p>" : "")}
                                <hr style='border: none; border-top: 2px dashed #ddd; margin: 18px 0;' />
                                <p style='margin: 0; font-size: 16px; color: #2d2d2d; font-weight: 600;'>TỔNG THANH TOÁN: <span style='color: #d9534f; font-size: 24px; font-weight: bold; margin-left: 8px;'>{totalAmount:N0} VNĐ</span></p>
                            </div>

                            <div style='margin-top: 40px; padding-top: 20px; border-top: 1px solid #eaeaea; text-align: center; font-size: 13px; color: #888;'>
                                <p style='margin: 5px 0;'>Cảm ơn bạn đã đồng hành cùng My Furniture Store. Chúng tôi cam kết đem đến sản phẩm và dịch vụ tốt nhất.</p>
                                <p style='margin: 8px 0; font-weight: bold; color: #d4af37;'>✨ Chúc bạn có những trải nghiệm không gian sống tuyệt vời! ✨</p>
                            </div>
                        </div>
                    </div>"
                };
                mailMessage.To.Add(toEmail);
                client.Send(mailMessage);
                Console.WriteLine($"[SMTP ORDER] Đã gửi Phiếu Xác Nhận Đặt Hàng #{orderCode} về mail {toEmail} thành công!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SMTP ORDER ERROR] Không thể gửi Phiếu Xác Nhận Đặt Hàng: {ex.Message}");
            }
        }

        public class CreateOrderRequest
        {
            public int UserId { get; set; }
            public string ShippingAddress { get; set; }
            public List<OrderItemRequest> Items { get; set; }
            public string? PaymentMethod { get; set; }
            public decimal ShippingFee { get; set; } = 0;
            public double? DeliveryDistanceKm { get; set; }
            public DateTime? EstimatedDeliveryDate { get; set; }
            public string? DeliveryTimeSlot { get; set; }
            public bool IncludesAssembly { get; set; } = false;
            public decimal AssemblyFee { get; set; } = 0;
            public string? VoucherCode { get; set; }
            public decimal DiscountAmount { get; set; } = 0;
            public string RecipientName { get; set; } = string.Empty;
            public string RecipientPhone { get; set; } = string.Empty;
            public string? RecipientEmail { get; set; }
            public string? CustomerNote { get; set; }
        }

        public class OrderItemRequest
        {
            public int ProductVariantId { get; set; }
            public int Quantity { get; set; }
        }

        public class UpdateStatusRequest
        {
            public string Status { get; set; }
        }

        public class CalculateShippingRequest
        {
            public double DistanceKm { get; set; }
            public bool IncludesAssembly { get; set; }
        }

        public class AssignShipperRequest
        {
            public int ShipperId { get; set; }
        }

        public class CompleteDeliveryRequest
        {
            public string? DeliveryProofImage { get; set; }
            public string? RecipientName { get; set; }
        }
    }
}

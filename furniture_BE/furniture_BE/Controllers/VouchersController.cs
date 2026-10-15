using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VouchersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public VouchersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/vouchers/admin
        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminVouchers()
        {
            try
            {
                var vouchers = await _context.Vouchers
                    .OrderByDescending(v => v.CreatedAt)
                    .ToListAsync();
                return Ok(vouchers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // GET: api/vouchers/active
        [HttpGet("active")]
        public async Task<IActionResult> GetActiveVouchers()
        {
            try
            {
                var now = DateTime.Now;
                var activeVouchers = await _context.Vouchers
                    .Where(v => v.IsActive && v.EndDate >= now && v.UsedCount < v.UsageLimit)
                    .OrderBy(v => v.MinOrderAmount)
                    .ToListAsync();
                return Ok(activeVouchers);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // POST: api/vouchers/validate
        [HttpPost("validate")]
        public async Task<IActionResult> ValidateVoucher([FromBody] ValidateVoucherRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.VoucherCode))
                {
                    return BadRequest(new { Message = "Vui lòng nhập mã khuyến mãi." });
                }

                var code = request.VoucherCode.Trim().ToUpper();
                var voucher = await _context.Vouchers.FirstOrDefaultAsync(v => v.VoucherCode.ToUpper() == code);

                if (voucher == null)
                {
                    return BadRequest(new { Message = "Mã giảm giá không tồn tại." });
                }

                if (!voucher.IsActive)
                {
                    return BadRequest(new { Message = "Mã giảm giá hiện không được kích hoạt." });
                }

                if (DateTime.Now < voucher.StartDate || DateTime.Now > voucher.EndDate)
                {
                    return BadRequest(new { Message = "Mã giảm giá đã hết hạn hoặc chưa đến thời gian sử dụng." });
                }

                if (voucher.UsedCount >= voucher.UsageLimit)
                {
                    return BadRequest(new { Message = "Mã giảm giá đã được sử dụng hết lượt." });
                }

                if (request.OrderSubtotal < voucher.MinOrderAmount)
                {
                    return BadRequest(new { Message = $"Đơn hàng tối thiểu {voucher.MinOrderAmount:N0}đ để sử dụng mã này." });
                }

                decimal discountAmount = 0m;
                if (voucher.DiscountType == 1) // Percentage
                {
                    discountAmount = request.OrderSubtotal * (voucher.DiscountValue / 100m);
                    if (voucher.MaxDiscountAmount.HasValue && discountAmount > voucher.MaxDiscountAmount.Value)
                    {
                        discountAmount = voucher.MaxDiscountAmount.Value;
                    }
                }
                else if (voucher.DiscountType == 2) // Fixed amount
                {
                    discountAmount = voucher.DiscountValue;
                    if (discountAmount > request.OrderSubtotal)
                    {
                        discountAmount = request.OrderSubtotal;
                    }
                }

                return Ok(new
                {
                    VoucherId = voucher.VoucherId,
                    VoucherCode = voucher.VoucherCode,
                    VoucherName = voucher.VoucherName,
                    DiscountType = voucher.DiscountType,
                    DiscountAmount = discountAmount,
                    Message = "Áp dụng mã giảm giá thành công!"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // POST: api/vouchers/admin
        [HttpPost("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CreateVoucher([FromBody] Voucher voucher)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(voucher.VoucherCode))
                {
                    return BadRequest(new { Message = "Mã khuyến mãi không được để trống." });
                }

                voucher.VoucherCode = voucher.VoucherCode.Trim().ToUpper();
                var exists = await _context.Vouchers.AnyAsync(v => v.VoucherCode == voucher.VoucherCode);
                if (exists)
                {
                    return BadRequest(new { Message = "Mã khuyến mãi này đã tồn tại trong hệ thống." });
                }

                voucher.CreatedAt = DateTime.Now;
                _context.Vouchers.Add(voucher);
                await _context.SaveChangesAsync();

                return Ok(voucher);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi tạo mã giảm giá: " + ex.Message });
            }
        }

        // PUT: api/vouchers/admin/{id}
        [HttpPut("admin/{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateVoucher(int id, [FromBody] Voucher update)
        {
            try
            {
                var existing = await _context.Vouchers.FindAsync(id);
                if (existing == null)
                {
                    return NotFound(new { Message = "Không tìm thấy mã giảm giá." });
                }

                update.VoucherCode = update.VoucherCode.Trim().ToUpper();
                if (existing.VoucherCode != update.VoucherCode)
                {
                    var exists = await _context.Vouchers.AnyAsync(v => v.VoucherCode == update.VoucherCode && v.VoucherId != id);
                    if (exists)
                    {
                        return BadRequest(new { Message = "Mã khuyến mãi mới bị trùng lặp với mã khác." });
                    }
                }

                existing.VoucherCode = update.VoucherCode;
                existing.VoucherName = update.VoucherName;
                existing.Description = update.Description;
                existing.DiscountType = update.DiscountType;
                existing.DiscountValue = update.DiscountValue;
                existing.MaxDiscountAmount = update.MaxDiscountAmount;
                existing.MinOrderAmount = update.MinOrderAmount;
                existing.UsageLimit = update.UsageLimit;
                existing.StartDate = update.StartDate;
                existing.EndDate = update.EndDate;
                existing.IsActive = update.IsActive;
                existing.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();
                return Ok(existing);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi cập nhật mã giảm giá: " + ex.Message });
            }
        }

        // DELETE: api/vouchers/admin/{id}
        [HttpDelete("admin/{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteVoucher(int id)
        {
            try
            {
                var existing = await _context.Vouchers.FindAsync(id);
                if (existing == null)
                {
                    return NotFound(new { Message = "Không tìm thấy mã giảm giá." });
                }

                _context.Vouchers.Remove(existing);
                await _context.SaveChangesAsync();
                return Ok(new { Message = "Xóa mã giảm giá thành công." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi xóa mã giảm giá: " + ex.Message });
            }
        }
    }

    public class ValidateVoucherRequest
    {
        public string VoucherCode { get; set; } = string.Empty;
        public decimal OrderSubtotal { get; set; }
    }
}

using System;
using System.Linq;
using System.Threading.Tasks;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using furniture_BE.Extensions;
using furniture_BE.Services;
using BCrypt.Net;

namespace furniture_BE.Backend.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/users/admin/all
        [HttpGet("admin/all")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAllUsers()
        {
            try
            {
                var users = await _context.Users
                    .IgnoreQueryFilters()
                    .Include(u => u.Role)
                    .OrderByDescending(u => u.CreatedAt)
                    .Select(u => new
                    {
                        u.UserId,
                        u.FullName,
                        u.Email,
                        u.Phone,
                        u.RoleId,
                        RoleName = u.Role != null ? u.Role.RoleName : "Customer",
                        u.IsDeleted,
                        u.CreatedAt
                    })
                    .ToListAsync();

                return Ok(users);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // PUT: api/users/admin/update-role/{userId}
        [HttpPut("admin/update-role/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateUserRole(int userId, [FromBody] UpdateRoleRequest request)
        {
            try
            {
                var user = await _context.Users
                    .IgnoreQueryFilters()
                    .FirstOrDefaultAsync(u => u.UserId == userId);
                if (user == null)
                {
                    return NotFound(new { Message = "Không tìm thấy người dùng." });
                }

                if (request.RoleId != 1 && request.RoleId != 2 && request.RoleId != 3)
                {
                    return BadRequest(new { Message = "Vai trò không hợp lệ (1: Admin, 2: Customer, 3: Shipper)." });
                }

                if (user.RoleId == 3 && request.RoleId != 3)
                {
                    var hasActiveDeliveries = await _context.Orders.AnyAsync(o =>
                        o.ShipperId == user.UserId && DeliveryStatuses.Active.Contains(o.OrderStatus));
                    if (hasActiveDeliveries)
                    {
                        return BadRequest(new
                        {
                            Message = "Không thể đổi vai trò khi shipper còn đơn giao hàng đang hoạt động."
                        });
                    }
                }

                user.RoleId = request.RoleId;
                user.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();

                return Ok(new { Message = "Cập nhật vai trò thành công." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // PUT: api/users/admin/toggle-status/{userId}
        [HttpPut("admin/toggle-status/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ToggleUserStatus(int userId)
        {
            try
            {
                var user = await _context.Users
                    .IgnoreQueryFilters()
                    .FirstOrDefaultAsync(u => u.UserId == userId);
                if (user == null)
                {
                    return NotFound(new { Message = "Không tìm thấy người dùng." });
                }

                user.IsDeleted = !user.IsDeleted;
                user.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();

                string statusMsg = user.IsDeleted ? "Khóa tài khoản thành công." : "Mở khóa tài khoản thành công.";
                return Ok(new { Message = statusMsg, IsDeleted = user.IsDeleted });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // PUT: api/users/admin/reset-password/{userId}
        [HttpPut("admin/reset-password/{userId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ResetPassword(int userId, [FromBody] ResetPasswordRequest request)
        {
            try
            {
                var user = await _context.Users
                    .IgnoreQueryFilters()
                    .FirstOrDefaultAsync(u => u.UserId == userId);
                if (user == null)
                {
                    return NotFound(new { Message = "Không tìm thấy người dùng." });
                }

                string newPass = string.IsNullOrWhiteSpace(request.NewPassword) ? "123456" : request.NewPassword.Trim();
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPass);
                user.UpdatedAt = DateTime.Now;
                await _context.SaveChangesAsync();

                return Ok(new { Message = $"Đặt lại mật khẩu thành công. Mật khẩu mới là: {newPass}" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // PUT: api/users/update-profile/{userId}
        [HttpPut("update-profile/{userId}")]
        public async Task<IActionResult> UpdateProfile(int userId, [FromBody] UpdateProfileRequest request)
        {
            if (User.UserId() != userId && !User.IsInRole("Admin")) return Forbid();
            try
            {
                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    return NotFound(new { Message = "Không tìm thấy người dùng." });
                }

                user.FullName = request.FullName;
                user.Gender = request.Gender;
                user.DateOfBirth = request.DateOfBirth;
                user.Phone = request.Phone;
                user.UpdatedAt = DateTime.Now;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    Message = "Cập nhật thông tin tài khoản thành công.",
                    User = new
                    {
                        user.UserId,
                        user.FullName,
                        user.Email,
                        user.RoleId,
                        user.Gender,
                        user.DateOfBirth,
                        user.Phone
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống: " + ex.Message });
            }
        }
    }

    public class UpdateRoleRequest
    {
        public int RoleId { get; set; }
    }

    public class ResetPasswordRequest
    {
        public string NewPassword { get; set; }
    }

    public class UpdateProfileRequest
    {
        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string Phone { get; set; }
    }
}

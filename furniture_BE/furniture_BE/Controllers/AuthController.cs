using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using BCrypt.Net;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using furniture_BE.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private const int RegistrationLinkLifetimeMinutes = 30;
        private static readonly TimeSpan RegistrationResendCooldown = TimeSpan.FromSeconds(60);
        private const string QuickRegistrationResponse =
            "Nếu email hợp lệ và chưa có tài khoản, liên kết thiết lập mật khẩu sẽ được gửi trong ít phút.";

        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly JwtTokenService _jwt;
        private readonly SmtpEmailService _emailService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            AppDbContext context,
            IConfiguration configuration,
            JwtTokenService jwt,
            SmtpEmailService emailService,
            ILogger<AuthController> logger)
        {
            _context = context;
            _configuration = configuration;
            _jwt = jwt;
            _emailService = emailService;
            _logger = logger;
        }

        [HttpPost("quick-register")]
        public async Task<IActionResult> QuickRegister([FromBody] QuickRegisterDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (!_emailService.IsConfigured)
            {
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    Message = "Dịch vụ gửi email chưa được cấu hình. Vui lòng liên hệ quản trị viên."
                });
            }

            var email = NormalizeEmail(dto.Email);
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email);

            // Luôn trả về cùng một thông báo để không tiết lộ email đã có tài khoản hay chưa.
            if (user is { IsEmailVerified: true })
                return Ok(new { Message = QuickRegistrationResponse });

            var now = DateTime.UtcNow;
            if (user?.RegistrationEmailSentAt is DateTime lastSent
                && now - lastSent < RegistrationResendCooldown)
            {
                return Ok(new { Message = QuickRegistrationResponse });
            }

            if (user == null)
            {
                var emailPrefix = email.Split('@')[0];
                user = new User
                {
                    Email = email,
                    FullName = $"Khách hàng - {emailPrefix}",
                    Phone = string.Empty,
                    Gender = string.Empty,
                    // Tài khoản chưa thể đăng nhập trước khi hoàn tất liên kết.
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString("N")),
                    RoleId = 2,
                    CreatedAt = now,
                    IsDeleted = false,
                    IsEmailVerified = false
                };
                _context.Users.Add(user);
            }

            var rawToken = CreateRegistrationToken();
            user.RegistrationTokenHash = HashRegistrationToken(rawToken);
            user.RegistrationTokenExpiry = now.AddMinutes(RegistrationLinkLifetimeMinutes);
            user.RegistrationEmailSentAt = now;
            user.UpdatedAt = now;
            await _context.SaveChangesAsync();

            var frontendUrl = (_configuration["FrontendUrl"] ?? "http://localhost:8085").TrimEnd('/');
            var setupUrl = $"{frontendUrl}/#/set-password?token={Uri.EscapeDataString(rawToken)}";

            try
            {
                await _emailService.SendRegistrationLinkAsync(email, setupUrl);
            }
            catch (Exception ex)
            {
                // Không ghi raw token hoặc liên kết vào log.
                _logger.LogError(ex, "Không thể gửi email thiết lập mật khẩu tới địa chỉ đã yêu cầu.");
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    Message = "Dịch vụ email đang tạm thời gián đoạn. Vui lòng thử lại sau một phút."
                });
            }

            return Ok(new { Message = QuickRegistrationResponse });
        }

        [HttpGet("registration-link")]
        public async Task<IActionResult> GetRegistrationLink([FromQuery] string token)
        {
            var user = await FindPendingRegistrationAsync(token);
            if (user == null)
            {
                return BadRequest(new
                {
                    Message = "Liên kết thiết lập mật khẩu không hợp lệ, đã hết hạn hoặc đã được sử dụng."
                });
            }

            return Ok(new { user.Email });
        }

        [HttpPost("complete-registration")]
        public async Task<IActionResult> CompleteRegistration([FromBody] CompleteRegistrationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var tokenHash = HashRegistrationToken(dto.Token.Trim());
            var now = DateTime.UtcNow;
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            var affectedRows = await _context.Users
                .Where(u =>
                    !u.IsEmailVerified
                    && u.RegistrationTokenHash == tokenHash
                    && u.RegistrationTokenExpiry != null
                    && u.RegistrationTokenExpiry > now)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(u => u.FullName, dto.FullName.Trim())
                    .SetProperty(u => u.PasswordHash, passwordHash)
                    .SetProperty(u => u.IsEmailVerified, true)
                    .SetProperty(u => u.RegistrationTokenHash, (string?)null)
                    .SetProperty(u => u.RegistrationTokenExpiry, (DateTime?)null)
                    .SetProperty(u => u.RegistrationEmailSentAt, (DateTime?)null)
                    .SetProperty(u => u.UpdatedAt, now));

            if (affectedRows != 1)
            {
                return BadRequest(new
                {
                    Message = "Liên kết thiết lập mật khẩu không hợp lệ, đã hết hạn hoặc đã được sử dụng."
                });
            }

            return Ok(new { Message = "Thiết lập tài khoản thành công. Bạn có thể đăng nhập ngay bây giờ." });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var inputNormalized = (dto.Email ?? string.Empty).Replace(" ", string.Empty).ToLower();
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email.Replace(" ", string.Empty).ToLower() == inputNormalized ||
                u.FullName.Replace(" ", string.Empty).ToLower() == inputNormalized ||
                u.FullName.Replace(" ", string.Empty).ToLower().EndsWith(inputNormalized));

            if (user == null)
                return Unauthorized(new { Message = "Tài khoản (email hoặc họ tên) không tồn tại." });

            if (!user.IsEmailVerified)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    Message = "Tài khoản chưa hoàn tất thiết lập mật khẩu. Vui lòng dùng liên kết trong email đăng ký."
                });
            }

            if (!BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized(new { Message = "Sai mật khẩu." });

            return Ok(new
            {
                Message = "Đăng nhập thành công.",
                Token = _jwt.Create(user),
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

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var emailNorm = NormalizeEmail(dto.Email ?? string.Empty);
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email.Trim().ToLower() == emailNorm && u.IsEmailVerified);
            if (user == null)
                return NotFound(new { Message = "Email không gắn với tài khoản nào trong hệ thống." });

            var otp = Random.Shared.Next(100000, 999999).ToString();
            user.ResetPasswordOtp = otp;
            user.ResetPasswordExpiry = DateTime.UtcNow.AddMinutes(10);
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            try
            {
                var smtpHost = _configuration["SmtpSettings:Host"];
                var smtpPort = int.Parse(_configuration["SmtpSettings:Port"] ?? "587");
                var senderEmail = _configuration["SmtpSettings:SenderEmail"];
                var senderPass = _configuration["SmtpSettings:SenderPassword"];
                var senderName = _configuration["SmtpSettings:SenderName"] ?? "My Furniture Store";

                if (string.IsNullOrEmpty(smtpHost) || string.IsNullOrEmpty(senderEmail)
                    || string.IsNullOrEmpty(senderPass) || !_emailService.IsConfigured)
                {
                    return StatusCode(503, new { Message = "Dịch vụ gửi email chưa được cấu hình." });
                }

                using var client = new SmtpClient(smtpHost, smtpPort)
                {
                    Credentials = new NetworkCredential(senderEmail, senderPass),
                    EnableSsl = _configuration.GetValue("SmtpSettings:EnableSsl", true)
                };
                using var mailMessage = new MailMessage
                {
                    From = new MailAddress(senderEmail, senderName),
                    Subject = "[My Furniture Store] Mã xác thực khôi phục mật khẩu",
                    Body = $"""
                        <div style="font-family:Arial,sans-serif;max-width:600px;padding:20px;border:1px solid #e0e0e0">
                          <h2>My Furniture Store</h2>
                          <p>Xin chào {WebUtility.HtmlEncode(user.FullName)},</p>
                          <p>Mã xác thực đặt lại mật khẩu của bạn là:</p>
                          <div style="font-size:28px;font-weight:bold;letter-spacing:8px;margin:20px 0">{otp}</div>
                          <p>Mã có hiệu lực trong 10 phút. Không chia sẻ mã này với bất kỳ ai.</p>
                        </div>
                        """,
                    IsBodyHtml = true
                };
                mailMessage.To.Add(user.Email);
                await client.SendMailAsync(mailMessage);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Không thể gửi email khôi phục mật khẩu.");
                return StatusCode(503, new { Message = "Dịch vụ email đang tạm thời gián đoạn. Vui lòng thử lại sau." });
            }

            return Ok(new { Message = "Mã OTP khôi phục mật khẩu đã được gửi tới email của bạn." });
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var emailNorm = NormalizeEmail(dto.Email ?? string.Empty);
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email.Trim().ToLower() == emailNorm && u.IsEmailVerified);
            if (user == null)
                return NotFound(new { Message = "Email không tồn tại." });

            if (user.ResetPasswordOtp != dto.Otp.Trim())
                return BadRequest(new { Message = "Mã OTP không chính xác." });

            if (user.ResetPasswordExpiry == null || user.ResetPasswordExpiry < DateTime.UtcNow)
                return BadRequest(new { Message = "Mã OTP đã hết hạn. Vui lòng gửi lại mã mới." });

            return Ok(new { Message = "Xác thực OTP thành công." });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var emailNorm = NormalizeEmail(dto.Email ?? string.Empty);
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email.Trim().ToLower() == emailNorm && u.IsEmailVerified);
            if (user == null)
                return NotFound(new { Message = "Email không tồn tại." });

            if (user.ResetPasswordOtp != dto.Otp.Trim()
                || user.ResetPasswordExpiry == null
                || user.ResetPasswordExpiry < DateTime.UtcNow)
            {
                return BadRequest(new { Message = "Mã xác thực không hợp lệ hoặc đã hết hạn." });
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            user.ResetPasswordOtp = null;
            user.ResetPasswordExpiry = null;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đặt lại mật khẩu thành công. Bạn có thể đăng nhập ngay bây giờ." });
        }

        private async Task<User?> FindPendingRegistrationAsync(string? rawToken)
        {
            if (string.IsNullOrWhiteSpace(rawToken) || rawToken.Length > 256)
                return null;

            var tokenHash = HashRegistrationToken(rawToken.Trim());
            var now = DateTime.UtcNow;
            return await _context.Users.FirstOrDefaultAsync(u =>
                !u.IsEmailVerified
                && u.RegistrationTokenHash == tokenHash
                && u.RegistrationTokenExpiry != null
                && u.RegistrationTokenExpiry > now);
        }

        private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();

        private static string CreateRegistrationToken()
        {
            var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
            return token.TrimEnd('=').Replace('+', '-').Replace('/', '_');
        }

        private static string HashRegistrationToken(string token)
        {
            return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token))).ToLowerInvariant();
        }
    }
}

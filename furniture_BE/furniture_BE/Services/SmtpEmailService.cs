using System.Net;
using System.Net.Mail;

namespace furniture_BE.Services
{
    public class SmtpEmailService
    {
        private readonly IConfiguration _configuration;

        public SmtpEmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public bool IsConfigured
        {
            get
            {
                var host = _configuration["SmtpSettings:Host"];
                var senderEmail = _configuration["SmtpSettings:SenderEmail"];
                var senderPassword = _configuration["SmtpSettings:SenderPassword"];
                return !string.IsNullOrWhiteSpace(host)
                    && !string.IsNullOrWhiteSpace(senderEmail)
                    && !string.IsNullOrWhiteSpace(senderPassword)
                    && !senderEmail.Contains("nhap_", StringComparison.OrdinalIgnoreCase)
                    && senderPassword != "app_password_demo_placeholder";
            }
        }

        public Task SendRegistrationLinkAsync(string recipientEmail, string setupUrl)
        {
            var safeUrl = WebUtility.HtmlEncode(setupUrl);
            return SendHtmlEmailAsync(
                recipientEmail,
                "[My Furniture Store] Thiết lập mật khẩu tài khoản",
                $"""
                <h2 style="color:#2d2d2d">My Furniture Store</h2>
                <p>Bạn vừa yêu cầu đăng ký tài khoản bằng email này.</p>
                <p>Hãy bấm nút bên dưới để đặt họ tên và mật khẩu. Liên kết chỉ dùng được một lần và hết hạn sau 30 phút.</p>
                <p style="margin:28px 0"><a href="{safeUrl}" style="background:#2d2d2d;color:white;text-decoration:none;padding:14px 22px;display:inline-block">THIẾT LẬP MẬT KHẨU</a></p>
                <p style="color:#666;font-size:13px">Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email.</p>
                """);
        }

        public Task SendReviewReplyNotificationAsync(
            string recipientEmail,
            string? fullName,
            string productName,
            int rating,
            string? comment,
            string reply)
        {
            return SendHtmlEmailAsync(
                recipientEmail,
                $"[My Furniture Store] Phản hồi đánh giá về {productName}",
                $"""
                <h2 style="margin-top:0;color:#ff471a">Đánh giá của bạn đã được phản hồi</h2>
                <p>Xin chào <strong>{Encode(fullName, "Quý khách")}</strong>,</p>
                <p>Quản trị viên vừa phản hồi đánh giá của bạn về <strong>{Encode(productName)}</strong> ({rating}/5 sao).</p>
                <div style="background:#f5f5f5;border-left:4px solid #777;padding:14px;margin:18px 0"><strong>Đánh giá của bạn:</strong><br>{EncodeLines(comment, "Không có bình luận")}</div>
                <div style="background:#fff4ef;border-left:4px solid #ff471a;padding:14px;margin:18px 0"><strong>Phản hồi từ cửa hàng:</strong><br>{EncodeLines(reply)}</div>
                <p>Cảm ơn bạn đã mua sắm tại My Furniture Store.</p>
                """);
        }

        public Task SendQuestionAnswerNotificationAsync(
            string recipientEmail,
            string? fullName,
            string topic,
            string questionText,
            string answerText)
        {
            return SendHtmlEmailAsync(
                recipientEmail,
                $"[My Furniture Store] Câu hỏi của bạn đã được phản hồi: {topic}",
                $"""
                <h2 style="margin-top:0;color:#ff471a">Câu hỏi của bạn đã được trả lời</h2>
                <p>Xin chào <strong>{Encode(fullName, "Quý khách")}</strong>,</p>
                <p>Quản trị viên vừa phản hồi câu hỏi thuộc chủ đề <strong>{Encode(topic)}</strong>.</p>
                <div style="background:#f5f5f5;border-left:4px solid #777;padding:14px;margin:18px 0"><strong>Câu hỏi của bạn:</strong><br>{EncodeLines(questionText)}</div>
                <div style="background:#fff4ef;border-left:4px solid #ff471a;padding:14px;margin:18px 0"><strong>Phản hồi từ cửa hàng:</strong><br>{EncodeLines(answerText)}</div>
                <p>Cảm ơn bạn đã liên hệ My Furniture Store.</p>
                """);
        }

        public Task SendDeliveryOtpAsync(
            string recipientEmail,
            string? fullName,
            string orderCode,
            string otp,
            DateTime expiresAt)
        {
            return SendHtmlEmailAsync(
                recipientEmail,
                $"[My Furniture Store] Mã xác nhận giao hàng {orderCode}",
                $"""
                <h2 style="margin-top:0;color:#2563eb">Xác nhận nhận hàng</h2>
                <p>Xin chào <strong>{Encode(fullName, "Quý khách")}</strong>,</p>
                <p>Shipper đã đến để giao đơn <strong>{Encode(orderCode)}</strong>.</p>
                <p>Mã xác nhận của bạn là:</p>
                <div style="font-size:30px;font-weight:bold;letter-spacing:8px;color:#111;padding:16px 0">{Encode(otp)}</div>
                <p>Mã có hiệu lực đến <strong>{expiresAt:HH:mm dd/MM/yyyy}</strong>. Chỉ cung cấp mã cho shipper sau khi bạn đã kiểm tra hàng.</p>
                """);
        }

        private async Task SendHtmlEmailAsync(string recipientEmail, string subject, string content)
        {
            if (!IsConfigured)
                throw new InvalidOperationException("Dịch vụ email chưa được cấu hình.");
            if (string.IsNullOrWhiteSpace(recipientEmail))
                throw new ArgumentException("Email người nhận không hợp lệ.", nameof(recipientEmail));

            var host = _configuration["SmtpSettings:Host"]!;
            var port = int.TryParse(_configuration["SmtpSettings:Port"], out var configuredPort) ? configuredPort : 587;
            var senderEmail = _configuration["SmtpSettings:SenderEmail"]!;
            var senderPassword = _configuration["SmtpSettings:SenderPassword"]!;
            var senderName = _configuration["SmtpSettings:SenderName"] ?? "My Furniture Store";

            using var client = new SmtpClient(host, port)
            {
                Credentials = new NetworkCredential(senderEmail, senderPassword),
                EnableSsl = _configuration.GetValue("SmtpSettings:EnableSsl", true)
            };
            using var message = new MailMessage
            {
                From = new MailAddress(senderEmail, senderName),
                Subject = SanitizeSubject(subject),
                IsBodyHtml = true,
                Body = $"""
                    <div style="font-family:Arial,sans-serif;max-width:620px;margin:auto;border:1px solid #e5e5e5">
                      <div style="background:#1d1d1d;color:white;padding:18px 26px"><strong>MY FURNITURE STORE</strong></div>
                      <div style="padding:26px;color:#2d2d2d;line-height:1.6">{content}</div>
                      <div style="background:#f5f5f5;color:#777;padding:12px 26px;font-size:12px">Email thông báo tự động từ My Furniture Store.</div>
                    </div>
                    """
            };
            message.To.Add(recipientEmail);
            await client.SendMailAsync(message);
        }

        private static string Encode(string? value, string fallback = "") =>
            WebUtility.HtmlEncode(string.IsNullOrWhiteSpace(value) ? fallback : value.Trim());

        private static string EncodeLines(string? value, string fallback = "") =>
            Encode(value, fallback).Replace("\r\n", "<br>").Replace("\n", "<br>");

        private static string SanitizeSubject(string subject)
        {
            var sanitized = subject.Replace("\r", " ").Replace("\n", " ").Trim();
            return sanitized.Length <= 200 ? sanitized : sanitized[..200];
        }
    }
}

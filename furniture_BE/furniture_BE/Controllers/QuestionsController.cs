using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.Extensions;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class QuestionsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly SmtpEmailService _emailService;
        private readonly SupportRealtimeNotifier _realtime;
        private readonly ILogger<QuestionsController> _logger;

        public QuestionsController(
            AppDbContext context,
            SmtpEmailService emailService,
            SupportRealtimeNotifier realtime,
            ILogger<QuestionsController> logger)
        {
            _context = context;
            _emailService = emailService;
            _realtime = realtime;
            _logger = logger;
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateQuestion([FromBody] CreateQuestionRequest request)
        {
            try
            {
                var userId = User.UserId();
                if (userId <= 0)
                    return BadRequest(new { Message = "Người dùng không hợp lệ." });

                if (string.IsNullOrWhiteSpace(request.Topic) || string.IsNullOrWhiteSpace(request.QuestionText))
                    return BadRequest(new { Message = "Vui lòng chọn chủ đề và nhập nội dung câu hỏi." });

                var user = await _context.Users.FindAsync(userId);
                if (user == null || user.IsDeleted)
                    return BadRequest(new { Message = "Không tìm thấy thông tin người dùng." });

                var question = new SupportQuestion
                {
                    UserId = userId,
                    Topic = request.Topic.Trim(),
                    QuestionText = request.QuestionText.Trim(),
                    CreatedAt = DateTime.UtcNow,
                    Status = "Unanswered"
                };

                await using var transaction = await _context.Database.BeginTransactionAsync();
                _context.SupportQuestions.Add(question);
                await _context.SaveChangesAsync();

                var conversation = new SupportConversation
                {
                    UserId = userId,
                    LegacyQuestionId = question.QuestionId,
                    Topic = question.Topic,
                    Status = SupportConversationStatuses.WaitingAdmin,
                    CreatedAt = question.CreatedAt,
                    UpdatedAt = question.CreatedAt
                };
                conversation.Messages.Add(new SupportMessage
                {
                    SenderId = userId,
                    SenderRole = SupportSenderRoles.Customer,
                    MessageText = question.QuestionText,
                    SentAt = question.CreatedAt
                });
                _context.SupportConversations.Add(conversation);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                await _realtime.ConversationUpdatedAsync(conversation.ConversationId);
                return Ok(new
                {
                    Message = "Gửi câu hỏi hỗ trợ thành công! Chúng tôi sẽ sớm phản hồi cho bạn.",
                    Data = question
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create support question.");
                return StatusCode(500, new { Message = "Không thể gửi câu hỏi lúc này. Vui lòng thử lại sau." });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserQuestions(int userId)
        {
            try
            {
                if (userId != User.UserId() && !User.IsInRole("Admin"))
                    return Forbid();

                var questions = await _context.SupportQuestions
                    .Where(q => q.UserId == userId)
                    .OrderByDescending(q => q.CreatedAt)
                    .ToListAsync();
                return Ok(questions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load support questions for user {UserId}.", userId);
                return StatusCode(500, new { Message = "Không thể tải câu hỏi lúc này." });
            }
        }

        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminQuestions()
        {
            try
            {
                var questions = await _context.SupportQuestions
                    .Include(q => q.User)
                    .OrderByDescending(q => q.CreatedAt)
                    .Select(q => new
                    {
                        q.QuestionId,
                        q.UserId,
                        FullName = q.User != null ? q.User.FullName : "Khách hàng ẩn danh",
                        Email = q.User != null ? q.User.Email : "",
                        q.Topic,
                        q.QuestionText,
                        q.CreatedAt,
                        q.AnswerText,
                        q.AnsweredAt,
                        q.Status
                    })
                    .ToListAsync();
                return Ok(questions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to load admin support questions.");
                return StatusCode(500, new { Message = "Không thể tải danh sách câu hỏi lúc này." });
            }
        }

        [HttpPut("admin/{id}/answer")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AnswerQuestion(int id, [FromBody] AnswerQuestionRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.AnswerText))
                return BadRequest(new { Message = "Vui lòng nhập nội dung câu trả lời." });
            if (request.AnswerText.Trim().Length > 4000)
                return BadRequest(new { Message = "Nội dung câu trả lời không được vượt quá 4.000 ký tự." });

            try
            {
                var question = await _context.SupportQuestions
                    .Include(q => q.User)
                    .FirstOrDefaultAsync(q => q.QuestionId == id);
                if (question == null)
                    return NotFound(new { Message = "Không tìm thấy câu hỏi này." });

                await using var transaction = await _context.Database.BeginTransactionAsync();
                question.AnswerText = request.AnswerText.Trim();
                question.AnsweredAt = DateTime.UtcNow;
                question.Status = "Answered";

                var adminId = User.UserId();
                var conversation = await _context.SupportConversations
                    .Include(c => c.Messages)
                    .FirstOrDefaultAsync(c => c.LegacyQuestionId == question.QuestionId);
                if (conversation == null)
                {
                    conversation = new SupportConversation
                    {
                        UserId = question.UserId,
                        AssignedAdminId = adminId,
                        LegacyQuestionId = question.QuestionId,
                        Topic = question.Topic,
                        Status = SupportConversationStatuses.WaitingCustomer,
                        CreatedAt = question.CreatedAt,
                        UpdatedAt = question.AnsweredAt.Value
                    };
                    conversation.Messages.Add(new SupportMessage
                    {
                        SenderId = question.UserId,
                        SenderRole = SupportSenderRoles.Customer,
                        MessageText = question.QuestionText,
                        SentAt = question.CreatedAt,
                        ReadAt = question.AnsweredAt
                    });
                    _context.SupportConversations.Add(conversation);
                }

                conversation.AssignedAdminId ??= adminId;
                conversation.Status = SupportConversationStatuses.WaitingCustomer;
                conversation.UpdatedAt = question.AnsweredAt.Value;
                conversation.ClosedAt = null;
                var legacyAnswer = conversation.Messages
                    .Where(m => m.SenderRole == SupportSenderRoles.Admin)
                    .OrderBy(m => m.SentAt)
                    .FirstOrDefault();
                SupportMessage realtimeAnswerMessage;
                if (legacyAnswer == null)
                {
                    realtimeAnswerMessage = new SupportMessage
                    {
                        SenderId = adminId,
                        SenderRole = SupportSenderRoles.Admin,
                        MessageText = question.AnswerText,
                        SentAt = question.AnsweredAt.Value
                    };
                    conversation.Messages.Add(realtimeAnswerMessage);
                }
                else
                {
                    legacyAnswer.SenderId ??= adminId;
                    legacyAnswer.MessageText = question.AnswerText;
                    realtimeAnswerMessage = legacyAnswer;
                }
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                await _realtime.MessageReceivedAsync(
                    conversation.ConversationId,
                    realtimeAnswerMessage.MessageId);

                var emailSent = false;
                if (!string.IsNullOrWhiteSpace(question.User?.Email) && _emailService.IsConfigured)
                {
                    try
                    {
                        await _emailService.SendQuestionAnswerNotificationAsync(
                            question.User.Email,
                            question.User.FullName,
                            question.Topic,
                            question.QuestionText,
                            question.AnswerText);
                        emailSent = true;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to send Q&A answer email for question {QuestionId}.", id);
                    }
                }

                return Ok(new
                {
                    EmailSent = emailSent,
                    Message = emailSent
                        ? "Đã lưu câu trả lời và gửi email thông báo cho khách hàng."
                        : "Đã lưu câu trả lời, nhưng chưa thể gửi email thông báo. Vui lòng kiểm tra cấu hình SMTP."
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to answer support question {QuestionId}.", id);
                return StatusCode(500, new { Message = "Không thể lưu câu trả lời lúc này. Vui lòng thử lại sau." });
            }
        }
    }

    public class CreateQuestionRequest
    {
        public int UserId { get; set; }
        public string Topic { get; set; } = string.Empty;
        public string QuestionText { get; set; } = string.Empty;
    }

    public class AnswerQuestionRequest
    {
        public string AnswerText { get; set; } = string.Empty;
    }
}

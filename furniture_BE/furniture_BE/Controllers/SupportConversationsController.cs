using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using furniture_BE.Extensions;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers;

[ApiController]
[Route("api/support-conversations")]
[Authorize]
public sealed class SupportConversationsController : ControllerBase
{
    private const int MaxMessageLength = 4000;
    private readonly AppDbContext _context;
    private readonly SupportRealtimeNotifier _realtime;
    private readonly SmtpEmailService _emailService;
    private readonly ILogger<SupportConversationsController> _logger;

    public SupportConversationsController(
        AppDbContext context,
        SupportRealtimeNotifier realtime,
        SmtpEmailService emailService,
        ILogger<SupportConversationsController> logger)
    {
        _context = context;
        _realtime = realtime;
        _emailService = emailService;
        _logger = logger;
    }

    [HttpGet("mine")]
    public async Task<ActionResult<IReadOnlyList<SupportConversationDto>>> GetMine()
    {
        var userId = User.UserId();
        var conversations = await ConversationQuery()
            .Where(c => c.UserId == userId)
            .OrderByDescending(c => c.UpdatedAt)
            .Take(100)
            .ToListAsync();
        return Ok(conversations.Select(c => ToDto(c, SupportSenderRoles.Admin, false)).ToList());
    }

    [HttpGet("admin")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<IReadOnlyList<SupportConversationDto>>> GetAdmin(
        [FromQuery] string? status = null)
    {
        var query = ConversationQuery();
        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(c => c.Status == status.Trim());
        }

        var conversations = await query
            .OrderByDescending(c => c.UpdatedAt)
            .Take(200)
            .ToListAsync();
        return Ok(conversations.Select(c => ToDto(c, SupportSenderRoles.Customer, false)).ToList());
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SupportConversationDto>> GetById(int id)
    {
        var conversation = await ConversationQuery()
            .FirstOrDefaultAsync(c => c.ConversationId == id);
        if (conversation == null) return NotFound(new { Message = "Không tìm thấy cuộc trò chuyện hỗ trợ." });
        if (!CanAccess(conversation)) return Forbid();

        var unreadRole = User.IsInRole("Admin")
            ? SupportSenderRoles.Customer
            : SupportSenderRoles.Admin;
        return Ok(ToDto(conversation, unreadRole, true));
    }

    [HttpPost]
    [EnableRateLimiting("support-messages")]
    public async Task<ActionResult<SupportConversationDto>> Create(
        [FromBody] CreateSupportConversationRequest request)
    {
        var topic = request.Topic.Trim();
        var messageText = request.MessageText.Trim();
        if (topic.Length is < 1 or > 150)
            return BadRequest(new { Message = "Chủ đề phải có từ 1 đến 150 ký tự." });
        if (!ValidMessage(messageText))
            return BadRequest(new { Message = "Tin nhắn phải có từ 1 đến 4.000 ký tự." });

        var userId = User.UserId();
        if (request.ClientMessageId.HasValue)
        {
            var existing = await _context.SupportMessages
                .Include(m => m.Conversation)
                .FirstOrDefaultAsync(m => m.ClientMessageId == request.ClientMessageId);
            if (existing?.Conversation?.UserId == userId)
            {
                return await GetById(existing.ConversationId);
            }
            if (existing != null)
            {
                return Conflict(new { Message = "MÃ£ tin nháº¯n Ä‘Ã£ Ä‘Æ°á»£c sá»­ dá»¥ng." });
            }
        }

        var now = DateTime.UtcNow;
        var conversation = new SupportConversation
        {
            UserId = userId,
            Topic = topic,
            Status = SupportConversationStatuses.WaitingAdmin,
            CreatedAt = now,
            UpdatedAt = now
        };
        conversation.Messages.Add(new SupportMessage
        {
            SenderId = userId,
            SenderRole = SupportSenderRoles.Customer,
            MessageText = messageText,
            ClientMessageId = request.ClientMessageId,
            SentAt = now
        });
        _context.SupportConversations.Add(conversation);
        await _context.SaveChangesAsync();
        await _realtime.ConversationUpdatedAsync(conversation.ConversationId);

        var created = await ConversationQuery()
            .FirstAsync(c => c.ConversationId == conversation.ConversationId);
        return CreatedAtAction(
            nameof(GetById),
            new { id = conversation.ConversationId },
            ToDto(created, SupportSenderRoles.Admin, true));
    }

    [HttpPost("{id:int}/messages")]
    [EnableRateLimiting("support-messages")]
    public async Task<ActionResult<SupportMessageDto>> SendMessage(
        int id,
        [FromBody] SendSupportMessageRequest request)
    {
        var messageText = request.MessageText.Trim();
        if (!ValidMessage(messageText))
            return BadRequest(new { Message = "Tin nhắn phải có từ 1 đến 4.000 ký tự." });

        var conversation = await _context.SupportConversations
            .FirstOrDefaultAsync(c => c.ConversationId == id);
        if (conversation == null) return NotFound(new { Message = "Không tìm thấy cuộc trò chuyện hỗ trợ." });
        if (!CanAccess(conversation)) return Forbid();
        if (conversation.Status == SupportConversationStatuses.Closed)
            return Conflict(new { Message = "Cuộc trò chuyện đã đóng. Hãy mở lại trước khi gửi tin nhắn." });

        var senderId = User.UserId();
        if (request.ClientMessageId.HasValue)
        {
            var existing = await _context.SupportMessages
                .Include(m => m.Sender)
                .FirstOrDefaultAsync(m =>
                    m.ClientMessageId == request.ClientMessageId &&
                    m.SenderId == senderId);
            if (existing != null) return Ok(ToMessageDto(existing));
        }

        var isAdmin = User.IsInRole("Admin");
        var now = DateTime.UtcNow;
        var message = new SupportMessage
        {
            ConversationId = id,
            SenderId = senderId,
            SenderRole = isAdmin ? SupportSenderRoles.Admin : SupportSenderRoles.Customer,
            MessageText = messageText,
            ClientMessageId = request.ClientMessageId,
            SentAt = now
        };
        _context.SupportMessages.Add(message);
        conversation.UpdatedAt = now;
        conversation.Status = isAdmin
            ? SupportConversationStatuses.WaitingCustomer
            : SupportConversationStatuses.WaitingAdmin;
        if (isAdmin) conversation.AssignedAdminId ??= senderId;
        if (isAdmin && conversation.LegacyQuestionId.HasValue)
        {
            var legacyQuestion = await _context.SupportQuestions
                .FindAsync(conversation.LegacyQuestionId.Value);
            if (legacyQuestion != null)
            {
                legacyQuestion.AnswerText = messageText;
                legacyQuestion.AnsweredAt = now;
                legacyQuestion.Status = "Answered";
            }
        }
        await _context.SaveChangesAsync();
        await _realtime.MessageReceivedAsync(id, message.MessageId);
        if (isAdmin) await SendReplyEmailAsync(id, messageText);

        await _context.Entry(message).Reference(m => m.Sender).LoadAsync();
        return Ok(ToMessageDto(message));
    }

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        var conversation = await _context.SupportConversations
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.ConversationId == id);
        if (conversation == null) return NotFound(new { Message = "Không tìm thấy cuộc trò chuyện hỗ trợ." });
        if (!CanAccess(conversation)) return Forbid();

        var senderRole = User.IsInRole("Admin")
            ? SupportSenderRoles.Customer
            : SupportSenderRoles.Admin;
        var now = DateTime.UtcNow;
        await _context.SupportMessages
            .Where(m =>
                m.ConversationId == id &&
                m.SenderRole == senderRole &&
                m.ReadAt == null &&
                !m.IsDeleted)
            .ExecuteUpdateAsync(update => update.SetProperty(m => m.ReadAt, now));
        var readerRole = User.IsInRole("Admin")
            ? SupportSenderRoles.Admin
            : SupportSenderRoles.Customer;
        await _realtime.MessagesReadAsync(id, readerRole, now);
        return NoContent();
    }

    [HttpPut("{id:int}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateStatus(
        int id,
        [FromBody] UpdateSupportConversationStatusRequest request)
    {
        var status = request.Status.Trim();
        if (!SupportConversationStatuses.All.Contains(status))
            return BadRequest(new { Message = "Trạng thái cuộc trò chuyện không hợp lệ." });

        var conversation = await _context.SupportConversations.FindAsync(id);
        if (conversation == null) return NotFound(new { Message = "Không tìm thấy cuộc trò chuyện hỗ trợ." });
        conversation.Status = SupportConversationStatuses.All
            .First(value => value.Equals(status, StringComparison.OrdinalIgnoreCase));
        conversation.UpdatedAt = DateTime.UtcNow;
        conversation.ClosedAt = conversation.Status == SupportConversationStatuses.Closed
            ? conversation.UpdatedAt
            : null;
        await _context.SaveChangesAsync();
        await _realtime.ConversationUpdatedAsync(id);
        return NoContent();
    }

    [HttpPut("{id:int}/assign")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> AssignToMe(int id)
    {
        var conversation = await _context.SupportConversations.FindAsync(id);
        if (conversation == null)
            return NotFound(new { Message = "Không tìm thấy cuộc trò chuyện hỗ trợ." });

        var adminId = User.UserId();
        if (conversation.AssignedAdminId.HasValue &&
            conversation.AssignedAdminId.Value != adminId)
        {
            return Conflict(new { Message = "Cuộc trò chuyện đã được quản trị viên khác nhận xử lý." });
        }

        conversation.AssignedAdminId = adminId;
        conversation.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        await _realtime.ConversationUpdatedAsync(id);
        return NoContent();
    }

    private IQueryable<SupportConversation> ConversationQuery() =>
        _context.SupportConversations
            .AsNoTracking()
            .AsSplitQuery()
            .Include(c => c.User)
            .Include(c => c.AssignedAdmin)
            .Include(c => c.Messages.Where(m => !m.IsDeleted))
                .ThenInclude(m => m.Sender);

    private bool CanAccess(SupportConversation conversation) =>
        User.IsInRole("Admin") || conversation.UserId == User.UserId();

    private async Task SendReplyEmailAsync(int conversationId, string reply)
    {
        if (!_emailService.IsConfigured) return;
        try
        {
            var conversation = await _context.SupportConversations
                .AsNoTracking()
                .Include(c => c.User)
                .Include(c => c.Messages.Where(m =>
                    !m.IsDeleted && m.SenderRole == SupportSenderRoles.Customer))
                .FirstOrDefaultAsync(c => c.ConversationId == conversationId);
            if (string.IsNullOrWhiteSpace(conversation?.User?.Email)) return;

            var firstCustomerMessage = conversation.Messages
                .OrderBy(m => m.SentAt)
                .ThenBy(m => m.MessageId)
                .FirstOrDefault()?.MessageText ?? conversation.Topic;
            await _emailService.SendQuestionAnswerNotificationAsync(
                conversation.User.Email,
                conversation.User.FullName,
                conversation.Topic,
                firstCustomerMessage,
                reply);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to send support reply email for conversation {ConversationId}.",
                conversationId);
        }
    }

    private static bool ValidMessage(string message) =>
        message.Length is >= 1 and <= MaxMessageLength;

    private static SupportConversationDto ToDto(
        SupportConversation conversation,
        string unreadSenderRole,
        bool includeMessages)
    {
        var messages = conversation.Messages
            .Where(m => !m.IsDeleted)
            .OrderBy(m => m.SentAt)
            .ThenBy(m => m.MessageId)
            .Select(ToMessageDto)
            .ToList();
        return new SupportConversationDto
        {
            ConversationId = conversation.ConversationId,
            UserId = conversation.UserId,
            CustomerName = conversation.User?.FullName ?? string.Empty,
            CustomerEmail = conversation.User?.Email ?? string.Empty,
            AssignedAdminId = conversation.AssignedAdminId,
            AssignedAdminName = conversation.AssignedAdmin?.FullName,
            LegacyQuestionId = conversation.LegacyQuestionId,
            Topic = conversation.Topic,
            Status = conversation.Status,
            CreatedAt = conversation.CreatedAt,
            UpdatedAt = conversation.UpdatedAt,
            ClosedAt = conversation.ClosedAt,
            UnreadCount = conversation.Messages.Count(m =>
                !m.IsDeleted && m.SenderRole == unreadSenderRole && m.ReadAt == null),
            LastMessage = messages.LastOrDefault(),
            Messages = includeMessages ? messages : []
        };
    }

    private static SupportMessageDto ToMessageDto(SupportMessage message) => new()
    {
        MessageId = message.MessageId,
        ConversationId = message.ConversationId,
        SenderId = message.SenderId,
        SenderName = message.Sender?.FullName ?? string.Empty,
        SenderRole = message.SenderRole,
        MessageType = message.MessageType,
        MessageText = message.MessageText,
        ClientMessageId = message.ClientMessageId,
        SentAt = message.SentAt,
        ReadAt = message.ReadAt
    };
}

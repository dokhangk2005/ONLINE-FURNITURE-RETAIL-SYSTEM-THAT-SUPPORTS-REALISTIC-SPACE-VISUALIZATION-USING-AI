using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using furniture_BE.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Services;

public sealed class SupportRealtimeNotifier
{
    private readonly AppDbContext _context;
    private readonly IHubContext<SupportChatHub, ISupportChatClient> _hub;
    private readonly ILogger<SupportRealtimeNotifier> _logger;

    public SupportRealtimeNotifier(
        AppDbContext context,
        IHubContext<SupportChatHub, ISupportChatClient> hub,
        ILogger<SupportRealtimeNotifier> logger)
    {
        _context = context;
        _hub = hub;
        _logger = logger;
    }

    public async Task ConversationUpdatedAsync(int conversationId)
    {
        try
        {
            var conversation = await ConversationQuery()
                .FirstOrDefaultAsync(c => c.ConversationId == conversationId);
            if (conversation == null) return;

            await Task.WhenAll(
                _hub.Clients
                    .Group(SupportHubGroups.Admins)
                    .ConversationUpdated(ToConversationDto(
                        conversation,
                        SupportSenderRoles.Customer)),
                _hub.Clients
                    .Group(SupportHubGroups.User(conversation.UserId))
                    .ConversationUpdated(ToConversationDto(
                        conversation,
                        SupportSenderRoles.Admin)));
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to publish realtime update for support conversation {ConversationId}.",
                conversationId);
        }
    }

    public async Task MessageReceivedAsync(int conversationId, long messageId)
    {
        try
        {
            var message = await _context.SupportMessages
                .AsNoTracking()
                .Include(m => m.Sender)
                .FirstOrDefaultAsync(m => m.MessageId == messageId && !m.IsDeleted);
            if (message != null)
            {
                await _hub.Clients
                    .Group(SupportHubGroups.Conversation(conversationId))
                    .MessageReceived(ToMessageDto(message));
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to publish realtime message {MessageId}.",
                messageId);
        }

        await ConversationUpdatedAsync(conversationId);
    }

    public async Task MessagesReadAsync(
        int conversationId,
        string readerRole,
        DateTime readAt)
    {
        try
        {
            await _hub.Clients
                .Group(SupportHubGroups.Conversation(conversationId))
                .MessagesRead(new SupportMessagesReadDto
                {
                    ConversationId = conversationId,
                    ReaderRole = readerRole,
                    ReadAt = readAt
                });
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to publish read receipt for support conversation {ConversationId}.",
                conversationId);
        }

        await ConversationUpdatedAsync(conversationId);
    }

    private IQueryable<SupportConversation> ConversationQuery() =>
        _context.SupportConversations
            .AsNoTracking()
            .AsSplitQuery()
            .Include(c => c.User)
            .Include(c => c.AssignedAdmin)
            .Include(c => c.Messages.Where(m => !m.IsDeleted))
                .ThenInclude(m => m.Sender);

    private static SupportConversationDto ToConversationDto(
        SupportConversation conversation,
        string unreadSenderRole)
    {
        var lastMessage = conversation.Messages
            .Where(m => !m.IsDeleted)
            .OrderByDescending(m => m.SentAt)
            .ThenByDescending(m => m.MessageId)
            .FirstOrDefault();
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
                !m.IsDeleted &&
                m.SenderRole == unreadSenderRole &&
                m.ReadAt == null),
            LastMessage = lastMessage == null ? null : ToMessageDto(lastMessage),
            Messages = []
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

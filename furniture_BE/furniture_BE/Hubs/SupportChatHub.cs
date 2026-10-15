using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using furniture_BE.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Hubs;

[Authorize]
public sealed class SupportChatHub : Hub<ISupportChatClient>
{
    private readonly AppDbContext _context;

    public SupportChatHub(AppDbContext context)
    {
        _context = context;
    }

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.UserId() ?? 0;
        if (userId <= 0)
        {
            Context.Abort();
            return;
        }

        var group = Context.User!.IsInRole("Admin")
            ? SupportHubGroups.Admins
            : SupportHubGroups.User(userId);
        await Groups.AddToGroupAsync(Context.ConnectionId, group);
        await base.OnConnectedAsync();
    }

    public async Task JoinConversation(int conversationId)
    {
        if (!await CanAccessConversation(conversationId))
            throw new HubException("Bạn không có quyền truy cập cuộc trò chuyện này.");

        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            SupportHubGroups.Conversation(conversationId));
    }

    public Task LeaveConversation(int conversationId) =>
        Groups.RemoveFromGroupAsync(
            Context.ConnectionId,
            SupportHubGroups.Conversation(conversationId));

    public async Task SetTyping(int conversationId, bool isTyping)
    {
        if (!await CanAccessConversation(conversationId))
            throw new HubException("Bạn không có quyền truy cập cuộc trò chuyện này.");

        var senderId = Context.User?.UserId() ?? 0;
        var typing = new SupportTypingDto
        {
            ConversationId = conversationId,
            SenderId = senderId,
            SenderName = Context.User?.Identity?.Name ?? string.Empty,
            SenderRole = Context.User?.IsInRole("Admin") == true
                ? SupportSenderRoles.Admin
                : SupportSenderRoles.Customer,
            IsTyping = isTyping
        };
        await Clients
            .OthersInGroup(SupportHubGroups.Conversation(conversationId))
            .TypingChanged(typing);
    }

    private async Task<bool> CanAccessConversation(int conversationId)
    {
        var query = _context.SupportConversations
            .AsNoTracking()
            .Where(c => c.ConversationId == conversationId);
        if (Context.User?.IsInRole("Admin") == true)
            return await query.AnyAsync();

        var userId = Context.User?.UserId() ?? 0;
        return userId > 0 && await query.AnyAsync(c => c.UserId == userId);
    }
}

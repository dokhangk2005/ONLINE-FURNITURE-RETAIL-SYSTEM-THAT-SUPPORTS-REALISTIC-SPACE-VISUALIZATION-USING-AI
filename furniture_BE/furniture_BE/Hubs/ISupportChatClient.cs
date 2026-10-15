using furniture_BE.DTOs;

namespace furniture_BE.Hubs;

public interface ISupportChatClient
{
    Task ConversationUpdated(SupportConversationDto conversation);
    Task MessageReceived(SupportMessageDto message);
    Task MessagesRead(SupportMessagesReadDto readReceipt);
    Task TypingChanged(SupportTypingDto typing);
}

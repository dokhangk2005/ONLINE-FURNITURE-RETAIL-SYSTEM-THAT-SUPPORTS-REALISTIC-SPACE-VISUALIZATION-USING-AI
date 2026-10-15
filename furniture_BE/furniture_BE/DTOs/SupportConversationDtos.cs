namespace furniture_BE.DTOs;

public sealed class CreateSupportConversationRequest
{
    public string Topic { get; set; } = string.Empty;
    public string MessageText { get; set; } = string.Empty;
    public Guid? ClientMessageId { get; set; }
}

public sealed class SendSupportMessageRequest
{
    public string MessageText { get; set; } = string.Empty;
    public Guid? ClientMessageId { get; set; }
}

public sealed class UpdateSupportConversationStatusRequest
{
    public string Status { get; set; } = string.Empty;
}

public sealed class SupportMessagesReadDto
{
    public int ConversationId { get; set; }
    public string ReaderRole { get; set; } = string.Empty;
    public DateTime ReadAt { get; set; }
}

public sealed class SupportTypingDto
{
    public int ConversationId { get; set; }
    public int SenderId { get; set; }
    public string SenderName { get; set; } = string.Empty;
    public string SenderRole { get; set; } = string.Empty;
    public bool IsTyping { get; set; }
}

public sealed class SupportMessageDto
{
    public long MessageId { get; set; }
    public int ConversationId { get; set; }
    public int? SenderId { get; set; }
    public string SenderName { get; set; } = string.Empty;
    public string SenderRole { get; set; } = string.Empty;
    public string MessageType { get; set; } = string.Empty;
    public string MessageText { get; set; } = string.Empty;
    public Guid? ClientMessageId { get; set; }
    public DateTime SentAt { get; set; }
    public DateTime? ReadAt { get; set; }
}

public sealed class SupportConversationDto
{
    public int ConversationId { get; set; }
    public int UserId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public int? AssignedAdminId { get; set; }
    public string? AssignedAdminName { get; set; }
    public int? LegacyQuestionId { get; set; }
    public string Topic { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? ClosedAt { get; set; }
    public int UnreadCount { get; set; }
    public SupportMessageDto? LastMessage { get; set; }
    public List<SupportMessageDto> Messages { get; set; } = [];
}

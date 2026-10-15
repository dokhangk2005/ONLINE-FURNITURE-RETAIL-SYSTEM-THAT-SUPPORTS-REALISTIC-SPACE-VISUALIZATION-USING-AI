using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models;

public class SupportMessage
{
    [Key]
    public long MessageId { get; set; }

    public int ConversationId { get; set; }

    [ForeignKey(nameof(ConversationId))]
    public SupportConversation? Conversation { get; set; }

    public int? SenderId { get; set; }

    [ForeignKey(nameof(SenderId))]
    public User? Sender { get; set; }

    [Required]
    [MaxLength(20)]
    public string SenderRole { get; set; } = SupportSenderRoles.Customer;

    [Required]
    [MaxLength(20)]
    public string MessageType { get; set; } = SupportMessageTypes.Text;

    [Required]
    public string MessageText { get; set; } = string.Empty;

    public Guid? ClientMessageId { get; set; }
    public DateTime SentAt { get; set; } = DateTime.UtcNow;
    public DateTime? ReadAt { get; set; }
    public bool IsDeleted { get; set; }
}

public static class SupportSenderRoles
{
    public const string Customer = "Customer";
    public const string Admin = "Admin";
    public const string System = "System";
}

public static class SupportMessageTypes
{
    public const string Text = "Text";
}

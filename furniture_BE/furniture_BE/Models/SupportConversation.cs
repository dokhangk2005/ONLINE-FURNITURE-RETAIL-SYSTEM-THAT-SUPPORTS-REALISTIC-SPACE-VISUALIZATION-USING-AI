using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models;

public class SupportConversation
{
    [Key]
    public int ConversationId { get; set; }

    public int UserId { get; set; }

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    public int? AssignedAdminId { get; set; }

    [ForeignKey(nameof(AssignedAdminId))]
    public User? AssignedAdmin { get; set; }

    public int? LegacyQuestionId { get; set; }

    [ForeignKey(nameof(LegacyQuestionId))]
    public SupportQuestion? LegacyQuestion { get; set; }

    [Required]
    [MaxLength(150)]
    public string Topic { get; set; } = string.Empty;

    [Required]
    [MaxLength(30)]
    public string Status { get; set; } = SupportConversationStatuses.WaitingAdmin;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ClosedAt { get; set; }

    public ICollection<SupportMessage> Messages { get; set; } = [];
}

public static class SupportConversationStatuses
{
    public const string Open = "Open";
    public const string WaitingAdmin = "WaitingAdmin";
    public const string WaitingCustomer = "WaitingCustomer";
    public const string Closed = "Closed";

    public static readonly IReadOnlySet<string> All = new HashSet<string>(
        [Open, WaitingAdmin, WaitingCustomer, Closed],
        StringComparer.OrdinalIgnoreCase);
}

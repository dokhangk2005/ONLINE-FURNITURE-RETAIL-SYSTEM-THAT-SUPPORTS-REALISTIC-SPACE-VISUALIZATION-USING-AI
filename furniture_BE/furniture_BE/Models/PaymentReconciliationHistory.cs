using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models;

public sealed class PaymentReconciliationHistory
{
    [Key]
    public int PaymentReconciliationHistoryId { get; set; }

    public int PaymentId { get; set; }
    [ForeignKey(nameof(PaymentId))]
    public Payment Payment { get; set; } = null!;

    public int OrderId { get; set; }
    [ForeignKey(nameof(OrderId))]
    public Order Order { get; set; } = null!;

    public int ShipperId { get; set; }
    [ForeignKey(nameof(ShipperId))]
    public User Shipper { get; set; } = null!;

    public int? AdminId { get; set; }
    [ForeignKey(nameof(AdminId))]
    public User? Admin { get; set; }

    [MaxLength(40)]
    public string Action { get; set; } = string.Empty;

    [MaxLength(30)]
    public string Status { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }

    [MaxLength(500)]
    public string? ProofImage { get; set; }

    [MaxLength(500)]
    public string? Note { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;
}

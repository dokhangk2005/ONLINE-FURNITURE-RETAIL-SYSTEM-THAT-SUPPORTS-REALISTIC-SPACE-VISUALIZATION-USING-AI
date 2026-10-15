using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class Payment
    {
        [Key]
        public int PaymentId { get; set; }

        public int OrderId { get; set; }
        [ForeignKey("OrderId")]
        public Order Order { get; set; }

        [MaxLength(50)]
        public string PaymentMethod { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        public DateTime PaymentDate { get; set; } = DateTime.Now;

        [MaxLength(100)]
        public string TransactionId { get; set; }

        [MaxLength(50)]
        public string PaymentStatus { get; set; }

        public int? CollectedByShipperId { get; set; }
        [ForeignKey(nameof(CollectedByShipperId))]
        public User? CollectedByShipper { get; set; }

        public DateTime? CollectedAt { get; set; }

        [MaxLength(500)]
        public string? CollectionProofImage { get; set; }

        [MaxLength(500)]
        public string? CollectionNote { get; set; }

        [MaxLength(30)]
        public string HandoverStatus { get; set; } = "NotRequired";

        public DateTime? HandoverSubmittedAt { get; set; }
        public DateTime? HandoverConfirmedAt { get; set; }
        public int? HandoverConfirmedByAdminId { get; set; }
        [ForeignKey(nameof(HandoverConfirmedByAdminId))]
        public User? HandoverConfirmedByAdmin { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public ICollection<PaymentReconciliationHistory> ReconciliationHistory { get; set; } =
            new List<PaymentReconciliationHistory>();
    }
}

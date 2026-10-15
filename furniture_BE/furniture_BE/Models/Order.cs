using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class Order
    {
        [Key]
        public int OrderId { get; set; }

        [MaxLength(50)]
        public string? OrderCode { get; set; }

        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; }

        public int? ShipperId { get; set; }
        [ForeignKey("ShipperId")]
        public User? Shipper { get; set; }

        public DateTime OrderDate { get; set; } = DateTime.Now;

        [Required]
        [MaxLength(500)]
        public string ShippingAddress { get; set; }

        [Required, MaxLength(100)]
        public string RecipientName { get; set; } = string.Empty;

        [Required, MaxLength(20)]
        public string RecipientPhone { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? RecipientEmail { get; set; }

        [MaxLength(1000)]
        public string? CustomerNote { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        [MaxLength(50)]
        public string OrderStatus { get; set; } 

        [Column(TypeName = "decimal(18,2)")]
        public decimal ShippingFee { get; set; } = 0;

        public double? DeliveryDistanceKm { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        [MaxLength(50)]
        public string? DeliveryTimeSlot { get; set; }

        public bool IncludesAssembly { get; set; } = false;

        [Column(TypeName = "decimal(18,2)")]
        public decimal AssemblyFee { get; set; } = 0;

        [MaxLength(500)]
        public string? DeliveryProofImage { get; set; }

        [MaxLength(1000)]
        public string? DeliveryNotes { get; set; }

        public int DeliveryAttemptCount { get; set; } = 0;

        public DateTime? DeliveryAssignedAt { get; set; }
        public DateTime? DeliveryAssignmentExpiresAt { get; set; }
        public DateTime? DeliveryAcceptedAt { get; set; }
        public DateTime? DeliveryPickedUpAt { get; set; }
        public DateTime? DeliveryArrivedAt { get; set; }
        public DateTime? DeliveredAt { get; set; }

        public DateTime? DeliveryCancelledAt { get; set; }
        public int? DeliveryCancelledByShipperId { get; set; }
        [MaxLength(500)]
        public string? DeliveryCancellationReason { get; set; }
        [MaxLength(1000)]
        public string? DeliveryCancellationNote { get; set; }
        [MaxLength(500)]
        public string? DeliveryCancellationProofImage { get; set; }

        [MaxLength(200)]
        public string? DeliveryRecipientName { get; set; }
        [MaxLength(500)]
        public string? DeliveryIssueProofImage { get; set; }
        [MaxLength(64)]
        public string? DeliveryOtpHash { get; set; }
        public DateTime? DeliveryOtpExpiresAt { get; set; }
        public DateTime? DeliveryOtpVerifiedAt { get; set; }
        public int DeliveryOtpAttempts { get; set; } = 0;

        [MaxLength(50)]
        public string? VoucherCode { get; set; }

        public DateTime? UpdatedAt { get; set; }

        // 1 Đơn hàng có nhiều Chi tiết và có thể có nhiều Lần thanh toán (nếu lỗi)
        public ICollection<OrderDetail> OrderDetails { get; set; }
        public ICollection<Payment> Payments { get; set; }
    }
}

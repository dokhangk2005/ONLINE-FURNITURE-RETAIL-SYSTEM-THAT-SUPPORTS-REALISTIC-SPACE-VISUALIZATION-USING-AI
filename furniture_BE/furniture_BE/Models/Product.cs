using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class Product
    {
        [Key]
        public int ProductId { get; set; }

        public int CategoryId { get; set; }
        [ForeignKey("CategoryId")]
        public Category? Category { get; set; } // Navigation property

        [Required, MaxLength(200)]
        public string ProductName { get; set; }

        [MaxLength(50)]
        public string? ProductCode { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal BasePrice { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        [Range(typeof(decimal), "0", "90")]
        public decimal DiscountPercent { get; set; } = 0;

        public bool IsDiscountActive { get; set; } = false;
        public DateTime? DiscountStartAt { get; set; }
        public DateTime? DiscountEndAt { get; set; }

        public string? Description { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public double AverageRating { get; set; } = 0.0;
        public int ReviewCount { get; set; } = 0;

        public ICollection<ProductVariant>? ProductVariants { get; set; }

        [NotMapped]
        public int SoldCount { get; set; } = 0;

        [NotMapped]
        public bool HasActiveDiscount => IsDiscountActiveAt(DateTime.UtcNow);

        [NotMapped]
        public decimal DiscountedBasePrice => GetEffectivePrice(0, DateTime.UtcNow);

        public bool IsDiscountActiveAt(DateTime now)
        {
            if (!IsDiscountActive || DiscountPercent <= 0 || DiscountPercent > 90)
                return false;
            return (!DiscountStartAt.HasValue || DiscountStartAt.Value <= now)
                && (!DiscountEndAt.HasValue || DiscountEndAt.Value >= now);
        }

        public decimal GetEffectivePrice(decimal additionalPrice, DateTime now)
        {
            var originalPrice = BasePrice + additionalPrice;
            if (!IsDiscountActiveAt(now)) return originalPrice;
            return Math.Round(originalPrice * (100m - DiscountPercent) / 100m,
                0, MidpointRounding.AwayFromZero);
        }
    }
}

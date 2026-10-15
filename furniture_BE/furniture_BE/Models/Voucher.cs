using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class Voucher
    {
        [Key]
        public int VoucherId { get; set; }

        [Required, MaxLength(50)]
        public string VoucherCode { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string VoucherName { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }

        // 1: Percentage (%), 2: Fixed Amount (VND)
        public int DiscountType { get; set; } = 1;

        [Column(TypeName = "decimal(18,2)")]
        public decimal DiscountValue { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? MaxDiscountAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal MinOrderAmount { get; set; } = 0;

        public int UsageLimit { get; set; } = 100;
        public int UsedCount { get; set; } = 0;

        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime EndDate { get; set; } = DateTime.Now.AddMonths(3);

        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}

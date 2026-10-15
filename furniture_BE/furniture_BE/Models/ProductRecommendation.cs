using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class ProductRecommendation
    {
        [Key]
        public int Id { get; set; }

        public int ProductId { get; set; }
        
        public int RecommendedProductId { get; set; }

        [Column(TypeName = "decimal(18,4)")]
        public decimal Confidence { get; set; } // Tỉ lệ % khi mua ProductId thì cũng mua RecommendedProductId

        [Column(TypeName = "decimal(18,4)")]
        public decimal Support { get; set; } // Tần suất cặp này xuất hiện trên tổng số hóa đơn

        public DateTime LastUpdated { get; set; } = DateTime.Now;

        // Navigation properties
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        [ForeignKey("RecommendedProductId")]
        public Product? RecommendedProduct { get; set; }
    }
}

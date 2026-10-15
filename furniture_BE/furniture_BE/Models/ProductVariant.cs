using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace furniture_BE.Backend.Models
{
    public class ProductVariant
    {
        [Key]
        public int VariantId { get; set; }

        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        [JsonIgnore]
        public Product? Product { get; set; }

        [MaxLength(50)]
        public string Material { get; set; }

        [MaxLength(50)]
        public string Color { get; set; }

        [MaxLength(50)]
        public string? Size { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AdditionalPrice { get; set; }

        public int StockQuantity { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // 1 Biến thể có thể xuất hiện trong nhiều Chi tiết đơn hàng
        public ICollection<OrderDetail>? OrderDetails { get; set; }
        public ICollection<ProductImage>? ProductImages { get; set; }
    }
}
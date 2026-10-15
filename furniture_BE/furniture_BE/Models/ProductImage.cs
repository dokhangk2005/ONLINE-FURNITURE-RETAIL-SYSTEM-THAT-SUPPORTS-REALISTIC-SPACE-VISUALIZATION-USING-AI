using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace furniture_BE.Backend.Models
{
    public class ProductImage
    {
        [Key]
        public int ImageId { get; set; }

        public int VariantId { get; set; }
        [ForeignKey("VariantId")]
        [JsonIgnore]
        public ProductVariant? ProductVariant { get; set; }

        [Required]
        [MaxLength(255)]
        public string ImageUrl { get; set; }

        [NotMapped]
        public string DisplayImageUrl => ImageId > 0
            ? $"/uploads/products/by-id/{ImageId}"
            : ImageUrl;

        public bool IsThumbnail { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class Category
    {
        [Key]
        public int CategoryId { get; set; }

        [Required, MaxLength(100)]
        public string CategoryName { get; set; }

        [MaxLength(50)]
        public string? CategoryCode { get; set; }

        [MaxLength(255)]
        public string? ImageUrl { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // Mối quan hệ tự tham chiếu (Danh mục cha-con)
        public int? ParentCategoryId { get; set; }
        [ForeignKey("ParentCategoryId")]
        public Category? ParentCategory { get; set; }

        public ICollection<Category>? SubCategories { get; set; }

        // Mối quan hệ 1-Nhiều với Products
        public ICollection<Product>? Products { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace furniture_BE.DTOs
{
    public class CreateReviewDto
    {
        [Range(1, int.MaxValue)]
        public int OrderDetailId { get; set; }

        [Range(1, int.MaxValue)]
        public int ProductId { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(2000)]
        public string? Comment { get; set; }
    }
}

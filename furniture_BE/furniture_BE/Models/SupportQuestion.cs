using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class SupportQuestion
    {
        [Key]
        public int QuestionId { get; set; }

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User? User { get; set; }

        [Required]
        [MaxLength(150)]
        public string Topic { get; set; } = string.Empty;

        [Required]
        public string QuestionText { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public string? AnswerText { get; set; }

        public DateTime? AnsweredAt { get; set; }

        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Unanswered"; // "Unanswered" | "Answered"
    }
}

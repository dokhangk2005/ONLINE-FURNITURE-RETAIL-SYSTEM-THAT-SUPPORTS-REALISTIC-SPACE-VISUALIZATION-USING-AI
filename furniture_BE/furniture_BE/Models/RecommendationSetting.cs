using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class RecommendationSetting
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int Id { get; set; } = 1;

        public bool AprioriEnabled { get; set; } = true;
        public bool ContentBasedEnabled { get; set; } = true;
        public bool AutoRebuildEnabled { get; set; } = true;

        [Column(TypeName = "decimal(8,6)")]
        public decimal MinSupport { get; set; } = 0.01m;

        [Column(TypeName = "decimal(8,6)")]
        public decimal MinConfidence { get; set; } = 0.10m;

        public int MaxResults { get; set; } = 5;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}

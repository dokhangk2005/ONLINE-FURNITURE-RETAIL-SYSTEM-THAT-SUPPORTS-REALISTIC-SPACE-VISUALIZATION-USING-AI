using System.ComponentModel.DataAnnotations;

namespace furniture_BE.DTOs
{
    public class UpdateRecommendationSettingsDto
    {
        public bool AprioriEnabled { get; set; }
        public bool ContentBasedEnabled { get; set; }
        public bool AutoRebuildEnabled { get; set; }

        [Range(0.000001, 1)]
        public decimal MinSupport { get; set; }

        [Range(0.000001, 1)]
        public decimal MinConfidence { get; set; }

        [Range(1, 20)]
        public int MaxResults { get; set; }
    }
}

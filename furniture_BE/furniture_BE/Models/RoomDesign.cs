using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace furniture_BE.Backend.Models;

public class RoomDesign
{
    [Key]
    public Guid RoomDesignId { get; set; } = Guid.NewGuid();

    public int? UserId { get; set; }

    [ForeignKey(nameof(UserId))]
    [JsonIgnore]
    public User? User { get; set; }

    [Required, MaxLength(120)]
    public string Title { get; set; } = "Không gian của tôi";

    [Required, MaxLength(255)]
    public string RoomImagePath { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? PreviewImagePath { get; set; }

    [Required, MaxLength(64)]
    public string AccessTokenHash { get; set; } = string.Empty;

    public string SceneJson { get; set; } = "[]";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ExpiresAt { get; set; }
}

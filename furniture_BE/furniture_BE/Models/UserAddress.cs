using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models;

public class UserAddress
{
    [Key] public int AddressId { get; set; }
    public int UserId { get; set; }
    [ForeignKey(nameof(UserId))] public User User { get; set; } = null!;
    [Required, MaxLength(100)] public string RecipientName { get; set; } = string.Empty;
    [Required, MaxLength(20)] public string Phone { get; set; } = string.Empty;
    [Required, MaxLength(500)] public string AddressLine { get; set; } = string.Empty;
    [MaxLength(100)] public string? Label { get; set; }
    public bool IsDefault { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }
}

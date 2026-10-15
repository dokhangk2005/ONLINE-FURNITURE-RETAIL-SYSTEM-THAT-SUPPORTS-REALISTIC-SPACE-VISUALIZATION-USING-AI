using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace furniture_BE.Backend.Models
{
    public class User
    {
        [Key]
        public int UserId { get; set; }

        public int RoleId { get; set; }
        [ForeignKey("RoleId")]
        public Role Role { get; set; }

        [Required]
        [MaxLength(100)]
        public string Email { get; set; }

        [Required]
        [MaxLength(255)]
        public string PasswordHash { get; set; }

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; }

        [MaxLength(20)]
        public string Phone { get; set; } = string.Empty;

        [MaxLength(20)]
        public string Gender { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [MaxLength(20)]
        public string? ResetPasswordOtp { get; set; }
        public DateTime? ResetPasswordExpiry { get; set; }

        public bool IsEmailVerified { get; set; } = true;

        [MaxLength(64)]
        public string? RegistrationTokenHash { get; set; }
        public DateTime? RegistrationTokenExpiry { get; set; }
        public DateTime? RegistrationEmailSentAt { get; set; }

        public bool IsAvailableForDelivery { get; set; } = false;
        public DateTime? AvailabilityUpdatedAt { get; set; }

        [MaxLength(20)]
        public string DeliveryShiftStatus { get; set; } = "Offline";
        public DateTime? DeliveryShiftStartedAt { get; set; }
        public DateTime? DeliveryShiftEndedAt { get; set; }
        public DateTime? DeliveryBreakUntil { get; set; }

        [MaxLength(50)]
        public string? DeliveryVehicleType { get; set; }
        [MaxLength(30)]
        public string? DeliveryVehiclePlate { get; set; }
        [MaxLength(200)]
        public string? DeliveryServiceArea { get; set; }
        public bool CanHandleBulkyItems { get; set; } = false;
        public bool CanProvideAssembly { get; set; } = false;
        public int MaxConcurrentDeliveries { get; set; } = 3;

        // Mối quan hệ 1-Nhiều: 1 User có nhiều Đơn hàng (với vai trò khách hàng mua)
        [InverseProperty("User")]
        public ICollection<Order>? Orders { get; set; }

        // Mối quan hệ 1-Nhiều: 1 Shipper được phân công đi giao nhiều đơn hàng
        [InverseProperty("Shipper")]
        public ICollection<Order>? ShippedOrders { get; set; }

        // Mối quan hệ 1-Nhiều: 1 User có thể gửi nhiều câu hỏi hỗ trợ
        [InverseProperty("User")]
        public ICollection<SupportQuestion>? SupportQuestions { get; set; }
        [InverseProperty("User")]
        public ICollection<SupportConversation>? SupportConversations { get; set; }
        [InverseProperty("AssignedAdmin")]
        public ICollection<SupportConversation>? AssignedSupportConversations { get; set; }
        [InverseProperty("Sender")]
        public ICollection<SupportMessage>? SupportMessages { get; set; }
        public ICollection<UserAddress>? Addresses { get; set; }
        public ICollection<RoomDesign>? RoomDesigns { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace furniture_BE.Backend.Models
{
    public class Role
    {
        [Key]
        public int RoleId { get; set; }

        [Required]
        [MaxLength(50)]
        public string RoleName { get; set; }

        // Mối quan hệ 1-Nhiều: 1 Quyền có nhiều Người dùng
        public ICollection<User> Users { get; set; }
    }
}
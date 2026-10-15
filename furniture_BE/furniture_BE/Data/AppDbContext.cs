using furniture_BE.Backend.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Data;

namespace furniture_BE.Backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Khai báo 9 DbSet tương ứng 9 bảng
        public DbSet<Role> Roles { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductVariant> ProductVariants { get; set; }
        public DbSet<ProductImage> ProductImages { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<PaymentReconciliationHistory> PaymentReconciliationHistories { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Voucher> Vouchers { get; set; }
        public DbSet<SupportQuestion> SupportQuestions { get; set; }
        public DbSet<SupportConversation> SupportConversations { get; set; }
        public DbSet<SupportMessage> SupportMessages { get; set; }
        public DbSet<ProductRecommendation> ProductRecommendations { get; set; }
        public DbSet<RecommendationSetting> RecommendationSettings { get; set; }
        public DbSet<UserAddress> UserAddresses { get; set; }
        public DbSet<RoomDesign> RoomDesigns { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Cấu hình Global Query Filter cho Soft Delete ở đây
            modelBuilder.Entity<Category>().HasQueryFilter(c => !c.IsDeleted);
            modelBuilder.Entity<Product>().HasQueryFilter(p => !p.IsDeleted);
            modelBuilder.Entity<Product>()
                .ToTable(table => table.HasCheckConstraint(
                    "CK_Products_DiscountPercent",
                    "[DiscountPercent] >= 0 AND [DiscountPercent] <= 90"));
            modelBuilder.Entity<ProductVariant>().HasQueryFilter(v => !v.IsDeleted);
            modelBuilder.Entity<User>().HasQueryFilter(u => !u.IsDeleted);

            // Cấu hình Unique Index cho r.ProductId và r.UserId
            modelBuilder.Entity<Review>()
                .HasIndex(r => new { r.ProductId, r.UserId })
                .IsUnique();

            // Cấu hình cấu trúc bảng Recommendation để tránh Cascade Path
            modelBuilder.Entity<ProductRecommendation>()
                .HasOne(pr => pr.Product)
                .WithMany()
                .HasForeignKey(pr => pr.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ProductRecommendation>()
                .HasOne(pr => pr.RecommendedProduct)
                .WithMany()
                .HasForeignKey(pr => pr.RecommendedProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // Cấu hình Foreign Key cho Order -> User và Order -> Shipper để tránh vòng lặp cascade delete
            modelBuilder.Entity<Order>()
                .HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Order>()
                .HasOne(o => o.Shipper)
                .WithMany(u => u.ShippedOrders)
                .HasForeignKey(o => o.ShipperId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Voucher>()
                .HasIndex(v => v.VoucherCode)
                .IsUnique();

            modelBuilder.Entity<Order>()
                .HasIndex(o => o.OrderCode)
                .IsUnique()
                .HasFilter("[OrderCode] IS NOT NULL");

            modelBuilder.Entity<UserAddress>()
                .HasOne(a => a.User).WithMany(u => u.Addresses).HasForeignKey(a => a.UserId).OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<RoomDesign>()
                .HasOne(d => d.User)
                .WithMany(u => u.RoomDesigns)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.SetNull);

            modelBuilder.Entity<RoomDesign>()
                .HasIndex(d => d.UserId);

            modelBuilder.Entity<RoomDesign>()
                .HasIndex(d => d.ExpiresAt);

            modelBuilder.Entity<SupportConversation>()
                .HasOne(c => c.User)
                .WithMany(u => u.SupportConversations)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Payment>()
                .HasOne(p => p.CollectedByShipper)
                .WithMany()
                .HasForeignKey(p => p.CollectedByShipperId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Payment>()
                .HasOne(p => p.HandoverConfirmedByAdmin)
                .WithMany()
                .HasForeignKey(p => p.HandoverConfirmedByAdminId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasOne(h => h.Payment)
                .WithMany(p => p.ReconciliationHistory)
                .HasForeignKey(h => h.PaymentId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasOne(h => h.Order)
                .WithMany()
                .HasForeignKey(h => h.OrderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasOne(h => h.Shipper)
                .WithMany()
                .HasForeignKey(h => h.ShipperId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasOne(h => h.Admin)
                .WithMany()
                .HasForeignKey(h => h.AdminId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasIndex(h => new { h.ShipperId, h.CreatedAt });

            modelBuilder.Entity<PaymentReconciliationHistory>()
                .HasIndex(h => new { h.Status, h.CreatedAt });

            modelBuilder.Entity<SupportConversation>()
                .HasOne(c => c.AssignedAdmin)
                .WithMany(u => u.AssignedSupportConversations)
                .HasForeignKey(c => c.AssignedAdminId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<SupportConversation>()
                .HasOne(c => c.LegacyQuestion)
                .WithOne()
                .HasForeignKey<SupportConversation>(c => c.LegacyQuestionId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<SupportConversation>()
                .HasIndex(c => c.LegacyQuestionId)
                .IsUnique()
                .HasFilter("[LegacyQuestionId] IS NOT NULL");

            modelBuilder.Entity<SupportConversation>()
                .HasIndex(c => new { c.UserId, c.UpdatedAt });

            modelBuilder.Entity<SupportConversation>()
                .HasIndex(c => new { c.Status, c.UpdatedAt });

            modelBuilder.Entity<SupportConversation>()
                .HasIndex(c => new { c.AssignedAdminId, c.Status });

            modelBuilder.Entity<SupportMessage>()
                .HasOne(m => m.Conversation)
                .WithMany(c => c.Messages)
                .HasForeignKey(m => m.ConversationId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SupportMessage>()
                .HasOne(m => m.Sender)
                .WithMany(u => u.SupportMessages)
                .HasForeignKey(m => m.SenderId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<SupportMessage>()
                .HasIndex(m => new { m.ConversationId, m.SentAt, m.MessageId });

            modelBuilder.Entity<SupportMessage>()
                .HasIndex(m => m.ClientMessageId)
                .IsUnique()
                .HasFilter("[ClientMessageId] IS NOT NULL");

            // Seed default roles & sample vouchers
            modelBuilder.Entity<Role>().HasData(
                new Role { RoleId = 1, RoleName = "Admin" },
                new Role { RoleId = 2, RoleName = "Customer" },
                new Role { RoleId = 3, RoleName = "Shipper" }
            );

            var now = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Unspecified);
            modelBuilder.Entity<Voucher>().HasData(
                new Voucher
                {
                    VoucherId = 1,
                    VoucherCode = "GIAM10",
                    VoucherName = "Ưu đãi mua sắm nội thất 10%",
                    Description = "Giảm 10% cho đơn hàng từ 3 triệu VNĐ, giảm tối đa 500.000 VNĐ.",
                    DiscountType = 1, // Percent
                    DiscountValue = 10m,
                    MaxDiscountAmount = 500000m,
                    MinOrderAmount = 3000000m,
                    UsageLimit = 100,
                    UsedCount = 5,
                    StartDate = now,
                    EndDate = now.AddYears(1),
                    IsActive = true,
                    CreatedAt = now
                },
                new Voucher
                {
                    VoucherId = 2,
                    VoucherCode = "GIAM500K",
                    VoucherName = "Giảm thẳng 500k đơn VIP",
                    Description = "Giảm ngay 500.000 VNĐ cho đơn đặt hàng nội thất từ 6 triệu VNĐ.",
                    DiscountType = 2, // Fixed
                    DiscountValue = 500000m,
                    MaxDiscountAmount = null,
                    MinOrderAmount = 6000000m,
                    UsageLimit = 50,
                    UsedCount = 12,
                    StartDate = now,
                    EndDate = now.AddYears(1),
                    IsActive = true,
                    CreatedAt = now
                },
                new Voucher
                {
                    VoucherId = 3,
                    VoucherCode = "WELCOME200",
                    VoucherName = "Chào bạn mới ưu đãi 200k",
                    Description = "Giảm ngay 200.000 VNĐ cho đơn hàng từ 1.500.000 VNĐ.",
                    DiscountType = 2,
                    DiscountValue = 200000m,
                    MaxDiscountAmount = null,
                    MinOrderAmount = 1500000m,
                    UsageLimit = 200,
                    UsedCount = 45,
                    StartDate = now,
                    EndDate = now.AddYears(1),
                    IsActive = true,
                    CreatedAt = now
                }
            );
        }
    }
}

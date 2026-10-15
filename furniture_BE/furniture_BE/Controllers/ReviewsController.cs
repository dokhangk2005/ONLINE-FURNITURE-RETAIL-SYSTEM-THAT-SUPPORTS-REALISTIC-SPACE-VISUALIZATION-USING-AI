using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using System.Threading.Tasks;
using furniture_BE.Extensions;
using furniture_BE.DTOs;
using furniture_BE.Services;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ReviewModerationService _moderationService;
        private readonly SmtpEmailService _emailService;
        private readonly ILogger<ReviewsController> _logger;

        public ReviewsController(
            AppDbContext context,
            ReviewModerationService moderationService,
            SmtpEmailService emailService,
            ILogger<ReviewsController> logger)
        {
            _context = context;
            _moderationService = moderationService;
            _emailService = emailService;
            _logger = logger;
        }

        // POST: api/Reviews
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> CreateReview([FromBody] CreateReviewDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.UserId();
            var purchased = await _context.OrderDetails.AnyAsync(detail =>
                detail.OrderDetailId == dto.OrderDetailId
                && detail.ProductVariant.ProductId == dto.ProductId
                && detail.Order.UserId == userId
                && detail.Order.OrderStatus == "Delivered");
            if (!purchased)
            {
                return BadRequest(new
                {
                    Message = "Chỉ có thể đánh giá sản phẩm từ đơn hàng của bạn sau khi đã giao thành công."
                });
            }

            // 1. Kiểm tra xem User này đã đánh giá sản phẩm này chưa
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(review =>
                    review.ProductId == dto.ProductId && review.UserId == userId);

            if (existingReview != null)
            {
                return BadRequest(new { Message = "Bạn đã đánh giá sản phẩm này rồi." });
            }

            // 2. Tự động kiểm duyệt: Nếu bình luận trống/chỉ khoảng trắng -> Auto duyệt, ngược lại chờ Admin duyệt
            var comment = dto.Comment?.Trim();
            var moderation = await _moderationService.ModerateAsync(
                comment,
                HttpContext.RequestAborted);
            if (moderation.Decision == ReviewModerationDecision.Block)
            {
                return BadRequest(new
                {
                    Code = "REVIEW_CONTENT_BLOCKED",
                    Message = "Nội dung đánh giá chứa ngôn từ tục tĩu hoặc không phù hợp. Vui lòng chỉnh sửa trước khi gửi."
                });
            }

            var review = new Review
            {
                ProductId = dto.ProductId,
                UserId = userId,
                Rating = dto.Rating,
                Comment = comment,
                IsApproved = moderation.Decision == ReviewModerationDecision.Allow,
                CreatedAt = DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            // 3. Nếu được tự động duyệt, cập nhật lại điểm số trung bình của sản phẩm ngay lập tức
            if (review.IsApproved)
            {
                await RecalculateProductRatingAsync(review.ProductId);
            }

            return Ok(new { 
                review.ReviewId,
                review.IsApproved, 
                Message = review.IsApproved
                    ? "Đánh giá đã được AI kiểm duyệt và đăng thành công!"
                    : "Đánh giá đã được gửi và đang chờ admin kiểm duyệt thêm."
            });
        }

        // GET: api/Reviews/product/5
        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetProductReviews(int productId, [FromQuery] int? rating)
        {
            var query = _context.Reviews
                .Include(r => r.User)
                .Where(r => r.ProductId == productId && r.IsApproved)
                .AsQueryable();

            if (rating.HasValue)
            {
                query = query.Where(r => r.Rating == rating.Value);
            }

            var reviews = await query
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new {
                    r.ReviewId,
                    r.Rating,
                    r.Comment,
                    r.CreatedAt,
                    r.AdminReply,
                    r.AdminReplyAt,
                    UserFullName = r.User != null ? r.User.FullName : "Khách hàng"
                })
                .ToListAsync();

            return Ok(reviews);
        }

        // GET: api/Reviews/product/5/stats
        [HttpGet("product/{productId}/stats")]
        public async Task<IActionResult> GetProductReviewStats(int productId)
        {
            var approvedReviews = await _context.Reviews
                .Where(r => r.ProductId == productId && r.IsApproved)
                .ToListAsync();

            int totalCount = approvedReviews.Count;
            double average = totalCount > 0 ? Math.Round(approvedReviews.Average(r => r.Rating), 1) : 0.0;

            var breakdown = Enumerable.Range(1, 5).ToDictionary(
                star => star,
                star => new {
                    Count = approvedReviews.Count(r => r.Rating == star),
                    Percentage = totalCount > 0 
                        ? Math.Round((double)approvedReviews.Count(r => r.Rating == star) / totalCount * 100, 1) 
                        : 0.0
                }
            );

            return Ok(new {
                ProductId = productId,
                AverageRating = average,
                TotalCount = totalCount,
                Breakdown = breakdown
            });
        }

        // GET: api/Reviews/admin/pending
        [HttpGet("admin/pending")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetPendingReviews()
        {
            var pendingReviews = await _context.Reviews
                .Include(r => r.Product)
                .Include(r => r.User)
                .Where(r => !r.IsApproved)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new {
                    r.ReviewId,
                    r.Rating,
                    r.Comment,
                    r.CreatedAt,
                    ProductName = r.Product != null ? r.Product.ProductName : "Sản phẩm",
                    UserFullName = r.User != null ? r.User.FullName : "Khách hàng"
                })
                .ToListAsync();

            return Ok(pendingReviews);
        }

        // PUT: api/Reviews/admin/5/approve
        [HttpPut("admin/{reviewId}/approve")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ApproveReview(int reviewId)
        {
            var review = await _context.Reviews.FirstOrDefaultAsync(r => r.ReviewId == reviewId);
            if (review == null)
            {
                return NotFound(new { Message = "Không tìm thấy đánh giá" });
            }

            review.IsApproved = true;
            await _context.SaveChangesAsync();

            // Cập nhật điểm trung bình của sản phẩm
            await RecalculateProductRatingAsync(review.ProductId);

            return Ok(new { Message = "Đã phê duyệt đánh giá thành công." });
        }

        // DELETE: api/Reviews/admin/5
        [HttpDelete("admin/{reviewId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RejectReview(int reviewId)
        {
            var review = await _context.Reviews.FirstOrDefaultAsync(r => r.ReviewId == reviewId);
            if (review == null)
            {
                return NotFound(new { Message = "Không tìm thấy đánh giá" });
            }

            int productId = review.ProductId;
            bool wasApproved = review.IsApproved;

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();

            // Nếu đánh giá bị xóa từng được duyệt trước đó, tính lại điểm trung bình
            if (wasApproved)
            {
                await RecalculateProductRatingAsync(productId);
            }

            return Ok(new { Message = "Đã từ chối/xóa đánh giá thành công." });
        }

        // GET: api/Reviews/admin/products
        [HttpGet("admin/products")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminProductsSummary()
        {
            var products = await _context.Products
                .Select(p => new {
                    p.ProductId,
                    p.ProductName,
                    p.AverageRating,
                    TotalCount = _context.Reviews.Count(r => r.ProductId == p.ProductId),
                    PendingCount = _context.Reviews.Count(r => r.ProductId == p.ProductId && !r.IsApproved)
                })
                .ToListAsync();

            return Ok(products);
        }

        // GET: api/Reviews/admin/products/{productId}
        [HttpGet("admin/products/{productId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminProductReviews(int productId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Where(r => r.ProductId == productId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new {
                    r.ReviewId,
                    r.Rating,
                    r.Comment,
                    r.IsApproved,
                    r.CreatedAt,
                    r.AdminReply,
                    r.AdminReplyAt,
                    UserFullName = r.User != null ? r.User.FullName : "Khách hàng"
                })
                .ToListAsync();

            return Ok(reviews);
        }

        // PUT: api/Reviews/admin/{reviewId}/reply
        [HttpPut("admin/{reviewId}/reply")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ReplyToReview(int reviewId, [FromBody] AdminReplyRequest request)
        {
            var reply = request.Reply?.Trim();
            if (string.IsNullOrWhiteSpace(reply))
                return BadRequest(new { Message = "Vui lòng nhập nội dung phản hồi." });
            if (reply.Length > 2000)
                return BadRequest(new { Message = "Nội dung phản hồi không được vượt quá 2.000 ký tự." });

            var review = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .FirstOrDefaultAsync(r => r.ReviewId == reviewId);
            if (review == null)
            {
                return NotFound(new { Message = "Không tìm thấy đánh giá." });
            }

            review.AdminReply = reply;
            review.AdminReplyAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var emailSent = false;
            if (!string.IsNullOrWhiteSpace(review.User?.Email) && _emailService.IsConfigured)
            {
                try
                {
                    await _emailService.SendReviewReplyNotificationAsync(
                        review.User.Email,
                        review.User.FullName,
                        review.Product?.ProductName ?? "Sản phẩm",
                        review.Rating,
                        review.Comment,
                        reply);
                    emailSent = true;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to send review reply email for review {ReviewId}.", reviewId);
                }
            }

            return Ok(new
            {
                EmailSent = emailSent,
                Message = emailSent
                    ? "Đã lưu phản hồi và gửi email thông báo cho khách hàng."
                    : "Đã lưu phản hồi, nhưng chưa thể gửi email thông báo. Vui lòng kiểm tra cấu hình SMTP."
            });
        }

        public class AdminReplyRequest
        {
            public string Reply { get; set; } = string.Empty;
        }

        private async Task RecalculateProductRatingAsync(int productId)
        {
            var product = await _context.Products.IgnoreQueryFilters().FirstOrDefaultAsync(p => p.ProductId == productId);
            if (product != null)
            {
                var approvedReviews = await _context.Reviews
                    .Where(r => r.ProductId == productId && r.IsApproved)
                    .ToListAsync();

                if (approvedReviews.Any())
                {
                    product.AverageRating = Math.Round(approvedReviews.Average(r => r.Rating), 1);
                    product.ReviewCount = approvedReviews.Count;
                }
                else
                {
                    product.AverageRating = 0.0;
                    product.ReviewCount = 0;
                }
                await _context.SaveChangesAsync();
            }
        }
    }
}

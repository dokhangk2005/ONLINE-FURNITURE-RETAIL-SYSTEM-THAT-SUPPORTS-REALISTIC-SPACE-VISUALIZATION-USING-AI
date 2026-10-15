using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecommendationsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly RecommendationService _recommendations;

        public RecommendationsController(
            AppDbContext context,
            RecommendationService recommendations)
        {
            _context = context;
            _recommendations = recommendations;
        }

        [HttpGet("admin/dashboard")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminDashboard()
        {
            var settings = await _recommendations.GetSettingsAsync();
            var eligibleBaskets = await _recommendations.EligibleOrderDetails()
                .Select(detail => detail.OrderId)
                .Distinct()
                .CountAsync();
            var activeProducts = await _context.Products.CountAsync();
            var rulesCount = await _context.ProductRecommendations.CountAsync();
            var coveredProducts = await _context.ProductRecommendations
                .Select(rule => rule.ProductId)
                .Distinct()
                .CountAsync();
            var lastUpdated = await _context.ProductRecommendations
                .MaxAsync(rule => (DateTime?)rule.LastUpdated);
            var rules = await _context.ProductRecommendations
                .Include(rule => rule.Product)
                .Include(rule => rule.RecommendedProduct)
                .Where(rule => rule.Product != null && rule.RecommendedProduct != null)
                .OrderByDescending(rule => rule.Confidence)
                .ThenByDescending(rule => rule.Support)
                .Take(200)
                .Select(rule => new
                {
                    rule.Id,
                    rule.ProductId,
                    SourceProductName = rule.Product!.ProductName,
                    rule.RecommendedProductId,
                    RecommendedProductName = rule.RecommendedProduct!.ProductName,
                    rule.Support,
                    rule.Confidence,
                    rule.LastUpdated
                })
                .ToListAsync();

            return Ok(new
            {
                Settings = new
                {
                    settings.AprioriEnabled,
                    settings.ContentBasedEnabled,
                    settings.AutoRebuildEnabled,
                    settings.MinSupport,
                    settings.MinConfidence,
                    settings.MaxResults,
                    settings.UpdatedAt
                },
                Stats = new
                {
                    EligibleBaskets = eligibleBaskets,
                    RulesCount = rulesCount,
                    ActiveProducts = activeProducts,
                    CoveredProducts = coveredProducts,
                    CoveragePercent = activeProducts == 0
                        ? 0
                        : Math.Round(coveredProducts * 100.0 / activeProducts, 2),
                    LastUpdated = lastUpdated
                },
                Rules = rules
            });
        }

        [HttpPut("admin/settings")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateSettings(
            [FromBody] UpdateRecommendationSettingsDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var settings = await _recommendations.UpdateSettingsAsync(dto);
            return Ok(new
            {
                Message = "Đã lưu cấu hình thuật toán gợi ý.",
                settings.UpdatedAt
            });
        }

        [HttpPost("admin/rebuild")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Rebuild()
        {
            var result = await _recommendations.RebuildAsync();
            return Ok(result);
        }

        [HttpDelete("admin/rules")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ClearRules()
        {
            var deleted = await _recommendations.ClearRulesAsync();
            return Ok(new { Message = $"Đã xóa {deleted} luật gợi ý Apriori." });
        }

        // Giữ tương thích với API quản trị cũ.
        [HttpPost("run-apriori")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RunApriori(
            [FromQuery] decimal? minSupport,
            [FromQuery] decimal? minConfidence)
        {
            if (minSupport is <= 0 or > 1 || minConfidence is <= 0 or > 1)
                return BadRequest(new { Message = "Support và Confidence phải lớn hơn 0 và không vượt quá 1." });

            return Ok(await _recommendations.RebuildAsync(minSupport, minConfidence));
        }

        [HttpGet("frequently-bought/{productId}")]
        public async Task<IActionResult> GetFrequentlyBoughtTogether(int productId)
        {
            var settings = await _recommendations.GetSettingsAsync();
            if (!settings.AprioriEnabled) return Ok(new List<Product>());

            var recommendedIds = await _context.ProductRecommendations
                .Where(rule => rule.ProductId == productId)
                .OrderByDescending(rule => rule.Confidence)
                .ThenByDescending(rule => rule.Support)
                .Select(rule => rule.RecommendedProductId)
                .Take(settings.MaxResults)
                .ToListAsync();
            if (recommendedIds.Count == 0) return Ok(new List<Product>());

            var products = await _context.Products
                .Include(product => product.Category)
                .Include(product => product.ProductVariants!)
                    .ThenInclude(variant => variant.ProductImages)
                .Where(product => recommendedIds.Contains(product.ProductId))
                .ToListAsync();
            var sortedProducts = recommendedIds
                .Select(id => products.FirstOrDefault(product => product.ProductId == id))
                .Where(product => product != null)
                .ToList();
            return Ok(sortedProducts);
        }

        [HttpGet("similar/{productId}")]
        public async Task<IActionResult> GetSimilarProducts(int productId)
        {
            var settings = await _recommendations.GetSettingsAsync();
            if (!settings.ContentBasedEnabled) return Ok(new List<Product>());

            var product = await _context.Products
                .Include(item => item.ProductVariants)
                .FirstOrDefaultAsync(item => item.ProductId == productId);
            if (product == null) return NotFound();

            var materials = product.ProductVariants?
                .Select(variant => variant.Material)
                .Distinct()
                .ToList() ?? [];
            var colors = product.ProductVariants?
                .Select(variant => variant.Color)
                .Distinct()
                .ToList() ?? [];

            var candidates = await _context.Products
                .Include(item => item.Category)
                .Include(item => item.ProductVariants!)
                    .ThenInclude(variant => variant.ProductImages)
                .Where(item => item.ProductId != productId)
                .Where(item => item.CategoryId == product.CategoryId
                    || item.ProductVariants!.Any(variant =>
                        materials.Contains(variant.Material)
                        || colors.Contains(variant.Color)))
                .Take(Math.Max(settings.MaxResults * 3, 10))
                .ToListAsync();

            var similarProducts = candidates
                .Select(item => new
                {
                    Product = item,
                    Score = (item.CategoryId == product.CategoryId ? 4 : 0)
                        + (item.ProductVariants?.Any(variant => materials.Contains(variant.Material)) == true ? 2 : 0)
                        + (item.ProductVariants?.Any(variant => colors.Contains(variant.Color)) == true ? 1 : 0),
                    PriceDistance = Math.Abs(item.BasePrice - product.BasePrice)
                })
                .OrderByDescending(item => item.Score)
                .ThenBy(item => item.PriceDistance)
                .ThenBy(item => item.Product.ProductId)
                .Take(settings.MaxResults)
                .Select(item => item.Product)
                .ToList();
            return Ok(similarProducts);
        }
    }
}

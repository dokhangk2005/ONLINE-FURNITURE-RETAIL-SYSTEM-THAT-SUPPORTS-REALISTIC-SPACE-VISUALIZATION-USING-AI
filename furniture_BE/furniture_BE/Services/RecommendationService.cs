using System.Diagnostics;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.DTOs;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Services;

public sealed record RecommendationRebuildResult(
    bool Skipped,
    string Message,
    int TotalBaskets,
    int RulesGenerated,
    long TimeElapsedMs);

public class RecommendationService
{
    private readonly AppDbContext _context;

    public RecommendationService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<RecommendationSetting> GetSettingsAsync()
    {
        var settings = await _context.RecommendationSettings.FindAsync(1);
        if (settings != null) return settings;

        settings = new RecommendationSetting { Id = 1 };
        _context.RecommendationSettings.Add(settings);
        await _context.SaveChangesAsync();
        return settings;
    }

    public async Task<RecommendationSetting> UpdateSettingsAsync(UpdateRecommendationSettingsDto dto)
    {
        var settings = await GetSettingsAsync();
        settings.AprioriEnabled = dto.AprioriEnabled;
        settings.ContentBasedEnabled = dto.ContentBasedEnabled;
        settings.AutoRebuildEnabled = dto.AutoRebuildEnabled;
        settings.MinSupport = dto.MinSupport;
        settings.MinConfidence = dto.MinConfidence;
        settings.MaxResults = dto.MaxResults;
        settings.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return settings;
    }

    public async Task<RecommendationRebuildResult> RebuildAsync(
        decimal? minSupport = null,
        decimal? minConfidence = null,
        bool isAutomatic = false)
    {
        var stopwatch = Stopwatch.StartNew();
        var settings = await GetSettingsAsync();
        if (!settings.AprioriEnabled)
        {
            return new RecommendationRebuildResult(
                true,
                "Apriori đang tắt.",
                0,
                await _context.ProductRecommendations.CountAsync(),
                stopwatch.ElapsedMilliseconds);
        }
        if (isAutomatic && !settings.AutoRebuildEnabled)
        {
            return new RecommendationRebuildResult(
                true,
                "Tự động xây dựng lại đang tắt.",
                0,
                await _context.ProductRecommendations.CountAsync(),
                stopwatch.ElapsedMilliseconds);
        }

        var supportThreshold = minSupport ?? settings.MinSupport;
        var confidenceThreshold = minConfidence ?? settings.MinConfidence;
        var baskets = await EligibleOrderDetails()
            .GroupBy(detail => detail.OrderId)
            .Select(group => group
                .Select(detail => detail.ProductVariant!.ProductId)
                .Distinct()
                .ToList())
            .ToListAsync();

        var singles = baskets
            .SelectMany(basket => basket)
            .GroupBy(productId => productId)
            .ToDictionary(group => group.Key, group => group.Count());
        var pairs = new Dictionary<(int From, int To), int>();
        foreach (var basket in baskets)
        {
            foreach (var from in basket)
            {
                foreach (var to in basket.Where(productId => productId != from))
                {
                    pairs[(from, to)] = pairs.GetValueOrDefault((from, to)) + 1;
                }
            }
        }

        var now = DateTime.UtcNow;
        var rules = baskets.Count == 0
            ? []
            : pairs.Select(pair => new ProductRecommendation
                {
                    ProductId = pair.Key.From,
                    RecommendedProductId = pair.Key.To,
                    Support = (decimal)pair.Value / baskets.Count,
                    Confidence = (decimal)pair.Value / singles[pair.Key.From],
                    LastUpdated = now
                })
                .Where(rule => rule.Support >= supportThreshold
                    && rule.Confidence >= confidenceThreshold)
                .ToList();

        await using var transaction = await _context.Database.BeginTransactionAsync();
        _context.ProductRecommendations.RemoveRange(_context.ProductRecommendations);
        await _context.SaveChangesAsync();
        _context.ProductRecommendations.AddRange(rules);
        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        stopwatch.Stop();
        return new RecommendationRebuildResult(
            false,
            baskets.Count == 0
                ? "Không có đơn hàng đủ điều kiện để tạo luật."
                : "Phân tích Apriori thành công.",
            baskets.Count,
            rules.Count,
            stopwatch.ElapsedMilliseconds);
    }

    public async Task<int> ClearRulesAsync()
    {
        var count = await _context.ProductRecommendations.CountAsync();
        await _context.ProductRecommendations.ExecuteDeleteAsync();
        return count;
    }

    public IQueryable<OrderDetail> EligibleOrderDetails()
    {
        return _context.OrderDetails
            .Include(detail => detail.ProductVariant)
            .Include(detail => detail.Order)
                .ThenInclude(order => order.Payments)
            .Where(detail => detail.ProductVariant != null
                && detail.Order != null
                && detail.Order.OrderStatus != "Cancelled"
                && (detail.Order.OrderStatus == "Delivered"
                    || detail.Order.Payments.Any(payment => payment.PaymentStatus == "Success")));
    }
}

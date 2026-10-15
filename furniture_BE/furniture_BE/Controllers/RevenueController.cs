using furniture_BE.Backend.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers;

[Route("api/revenue")]
[ApiController]
[Authorize(Roles = "Admin")]
public class RevenueController : ControllerBase
{
    private readonly AppDbContext _context;

    public RevenueController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("admin/report")]
    public async Task<IActionResult> GetReport(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] string groupBy = "month")
    {
        groupBy = groupBy.Trim().ToLowerInvariant();
        if (groupBy is not ("day" or "month" or "year"))
            return BadRequest(new { message = "groupBy chỉ chấp nhận day, month hoặc year." });

        var today = DateTime.Today;
        var fromDate = (from ?? new DateTime(today.Year, 1, 1)).Date;
        var toDate = (to ?? today).Date;
        if (fromDate > toDate)
            return BadRequest(new { message = "Ngày bắt đầu không được lớn hơn ngày kết thúc." });

        var totalDays = (toDate - fromDate).TotalDays + 1;
        if ((groupBy == "day" && totalDays > 370) ||
            (groupBy == "month" && totalDays > 3660) ||
            (groupBy == "year" && totalDays > 14610))
        {
            return BadRequest(new
            {
                message = "Khoảng thời gian quá dài cho mức thống kê đã chọn. Theo ngày tối đa 370 ngày, theo tháng tối đa 10 năm và theo năm tối đa 40 năm."
            });
        }

        var toExclusive = toDate.AddDays(1);
        var rangeLength = toExclusive - fromDate;
        var previousToExclusive = fromDate;
        var previousFrom = previousToExclusive - rangeLength;

        var deliveredOrders = await _context.Orders
            .IgnoreQueryFilters()
            .AsNoTracking()
            .Where(order => order.OrderStatus == "Delivered")
            .Select(order => new
            {
                order.OrderId,
                order.UserId,
                RecognizedAt = order.UpdatedAt ?? order.OrderDate,
                order.TotalAmount,
                order.ShippingFee,
                order.AssemblyFee,
                order.VoucherCode
            })
            .ToListAsync();

        var currentOrders = deliveredOrders
            .Where(order => order.RecognizedAt >= fromDate && order.RecognizedAt < toExclusive)
            .ToList();
        var previousOrders = deliveredOrders
            .Where(order => order.RecognizedAt >= previousFrom && order.RecognizedAt < previousToExclusive)
            .ToList();

        var details = await _context.OrderDetails
            .IgnoreQueryFilters()
            .AsNoTracking()
            .Where(detail =>
                detail.Order.OrderStatus == "Delivered" &&
                (detail.Order.UpdatedAt ?? detail.Order.OrderDate) >= fromDate &&
                (detail.Order.UpdatedAt ?? detail.Order.OrderDate) < toExclusive)
            .Select(detail => new
            {
                detail.OrderId,
                detail.Quantity,
                detail.UnitPrice,
                ProductId = detail.ProductVariant.ProductId,
                ProductName = detail.ProductVariant.Product != null
                    ? detail.ProductVariant.Product.ProductName
                    : "Sản phẩm không xác định",
                ProductCode = detail.ProductVariant.Product != null
                    ? detail.ProductVariant.Product.ProductCode
                    : null,
                CategoryId = detail.ProductVariant.Product != null
                    ? detail.ProductVariant.Product.CategoryId
                    : 0,
                CategoryName = detail.ProductVariant.Product != null &&
                               detail.ProductVariant.Product.Category != null
                    ? detail.ProductVariant.Product.Category.CategoryName
                    : "Chưa phân loại"
            })
            .ToListAsync();

        var merchandiseRevenue = details.Sum(detail => detail.UnitPrice * detail.Quantity);
        var totalRevenue = currentOrders.Sum(order => order.TotalAmount);
        var shippingRevenue = currentOrders.Sum(order => order.ShippingFee);
        var assemblyRevenue = currentOrders.Sum(order => order.AssemblyFee);
        var estimatedDiscount = Math.Max(
            0,
            merchandiseRevenue + shippingRevenue + assemblyRevenue - totalRevenue);
        var totalItems = details.Sum(detail => detail.Quantity);

        var productGroups = details
            .GroupBy(detail => new
            {
                detail.ProductId,
                detail.ProductName,
                detail.ProductCode,
                detail.CategoryName
            })
            .Select(group => new
            {
                group.Key.ProductId,
                group.Key.ProductName,
                ProductCode = group.Key.ProductCode ?? string.Empty,
                group.Key.CategoryName,
                QuantitySold = group.Sum(item => item.Quantity),
                OrderCount = group.Select(item => item.OrderId).Distinct().Count(),
                Revenue = group.Sum(item => item.UnitPrice * item.Quantity)
            })
            .OrderByDescending(item => item.Revenue)
            .ToList();

        var products = productGroups.Select(item => new
        {
            item.ProductId,
            item.ProductName,
            item.ProductCode,
            item.CategoryName,
            item.QuantitySold,
            item.OrderCount,
            item.Revenue,
            AverageSellingPrice = item.QuantitySold == 0 ? 0 : item.Revenue / item.QuantitySold,
            SharePercent = merchandiseRevenue == 0 ? 0 : item.Revenue / merchandiseRevenue * 100
        });

        var categoryGroups = details
            .GroupBy(detail => new { detail.CategoryId, detail.CategoryName })
            .Select(group => new
            {
                group.Key.CategoryId,
                group.Key.CategoryName,
                QuantitySold = group.Sum(item => item.Quantity),
                OrderCount = group.Select(item => item.OrderId).Distinct().Count(),
                ProductCount = group.Select(item => item.ProductId).Distinct().Count(),
                Revenue = group.Sum(item => item.UnitPrice * item.Quantity)
            })
            .OrderByDescending(item => item.Revenue)
            .ToList();

        var categories = categoryGroups.Select(item => new
        {
            item.CategoryId,
            item.CategoryName,
            item.QuantitySold,
            item.OrderCount,
            item.ProductCount,
            item.Revenue,
            SharePercent = merchandiseRevenue == 0 ? 0 : item.Revenue / merchandiseRevenue * 100
        });

        var itemQuantityByOrder = details
            .GroupBy(detail => detail.OrderId)
            .ToDictionary(group => group.Key, group => group.Sum(item => item.Quantity));
        var timelineLookup = currentOrders
            .GroupBy(order => GetBucketStart(order.RecognizedAt, groupBy))
            .ToDictionary(
                group => group.Key,
                group => new
                {
                    Revenue = group.Sum(order => order.TotalAmount),
                    OrderCount = group.Count(),
                    ItemCount = group.Sum(order =>
                        itemQuantityByOrder.TryGetValue(order.OrderId, out var quantity) ? quantity : 0)
                });

        var timeline = EnumerateBuckets(fromDate, toDate, groupBy)
            .Select(bucket =>
            {
                timelineLookup.TryGetValue(bucket, out var point);
                return new
                {
                    PeriodStart = bucket,
                    Revenue = point?.Revenue ?? 0,
                    OrderCount = point?.OrderCount ?? 0,
                    ItemCount = point?.ItemCount ?? 0,
                    AverageOrderValue = point == null || point.OrderCount == 0
                        ? 0
                        : point.Revenue / point.OrderCount
                };
            })
            .ToList();

        var previousRevenue = previousOrders.Sum(order => order.TotalAmount);
        var previousOrderCount = previousOrders.Count;

        return Ok(new
        {
            Range = new
            {
                From = fromDate,
                To = toDate,
                GroupBy = groupBy,
                PreviousFrom = previousFrom.Date,
                PreviousTo = previousToExclusive.AddDays(-1).Date
            },
            Summary = new
            {
                TotalRevenue = totalRevenue,
                MerchandiseRevenue = merchandiseRevenue,
                ShippingRevenue = shippingRevenue,
                AssemblyRevenue = assemblyRevenue,
                EstimatedDiscount = estimatedDiscount,
                OrderCount = currentOrders.Count,
                ItemCount = totalItems,
                CustomerCount = currentOrders.Select(order => order.UserId).Distinct().Count(),
                AverageOrderValue = currentOrders.Count == 0 ? 0 : totalRevenue / currentOrders.Count,
                VoucherOrderCount = currentOrders.Count(order => !string.IsNullOrWhiteSpace(order.VoucherCode)),
                PreviousRevenue = previousRevenue,
                PreviousOrderCount = previousOrderCount,
                RevenueChangePercent = PercentChange(totalRevenue, previousRevenue),
                OrderChangePercent = PercentChange(currentOrders.Count, previousOrderCount)
            },
            Timeline = timeline,
            Products = products,
            Categories = categories
        });
    }

    private static decimal PercentChange(decimal current, decimal previous)
    {
        if (previous == 0) return current == 0 ? 0 : 100;
        return (current - previous) / previous * 100;
    }

    private static DateTime GetBucketStart(DateTime value, string groupBy) => groupBy switch
    {
        "day" => value.Date,
        "month" => new DateTime(value.Year, value.Month, 1),
        _ => new DateTime(value.Year, 1, 1)
    };

    private static IEnumerable<DateTime> EnumerateBuckets(
        DateTime from,
        DateTime to,
        string groupBy)
    {
        var current = GetBucketStart(from, groupBy);
        var last = GetBucketStart(to, groupBy);
        while (current <= last)
        {
            yield return current;
            current = groupBy switch
            {
                "day" => current.AddDays(1),
                "month" => current.AddMonths(1),
                _ => current.AddYears(1)
            };
        }
    }
}

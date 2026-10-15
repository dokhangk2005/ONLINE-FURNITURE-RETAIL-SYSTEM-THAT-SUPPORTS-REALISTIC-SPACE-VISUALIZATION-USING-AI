using furniture_BE.Backend.Data;
using furniture_BE.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Services;

public sealed class DeliveryRealtimeNotifier
{
    private readonly AppDbContext _context;
    private readonly IHubContext<DeliveryHub> _hub;
    private readonly ILogger<DeliveryRealtimeNotifier> _logger;

    public DeliveryRealtimeNotifier(
        AppDbContext context,
        IHubContext<DeliveryHub> hub,
        ILogger<DeliveryRealtimeNotifier> logger)
    {
        _context = context;
        _hub = hub;
        _logger = logger;
    }

    public async Task OrderUpdatedAsync(int orderId, string message, int? additionalShipperId = null)
    {
        try
        {
            var order = await _context.Orders.AsNoTracking()
                .Where(o => o.OrderId == orderId)
                .Select(o => new
                {
                    o.OrderId,
                    o.OrderCode,
                    o.OrderStatus,
                    o.UserId,
                    o.ShipperId,
                    o.UpdatedAt
                })
                .FirstOrDefaultAsync();
            if (order == null) return;

            var payload = new
            {
                order.OrderId,
                order.OrderCode,
                order.OrderStatus,
                Message = message,
                UpdatedAt = order.UpdatedAt ?? DateTime.Now
            };
            var tasks = new List<Task>
            {
                _hub.Clients.Group(DeliveryHubGroups.Admins)
                    .SendAsync("DeliveryUpdated", payload),
                _hub.Clients.Group(DeliveryHubGroups.Customer(order.UserId))
                    .SendAsync("DeliveryUpdated", payload)
            };
            if (order.ShipperId.HasValue)
            {
                tasks.Add(_hub.Clients.Group(DeliveryHubGroups.Shipper(order.ShipperId.Value))
                    .SendAsync("DeliveryUpdated", payload));
            }
            if (additionalShipperId.HasValue && additionalShipperId != order.ShipperId)
            {
                tasks.Add(_hub.Clients.Group(DeliveryHubGroups.Shipper(additionalShipperId.Value))
                    .SendAsync("DeliveryUpdated", payload));
            }
            await Task.WhenAll(tasks);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unable to publish delivery update for order {OrderId}.", orderId);
        }
    }
}

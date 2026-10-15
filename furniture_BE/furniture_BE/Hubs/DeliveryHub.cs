using furniture_BE.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace furniture_BE.Hubs;

public static class DeliveryHubGroups
{
    public const string Admins = "delivery:admins";
    public static string Shipper(int userId) => $"delivery:shipper:{userId}";
    public static string Customer(int userId) => $"delivery:customer:{userId}";
}

[Authorize]
public sealed class DeliveryHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.UserId() ?? 0;
        if (userId <= 0)
        {
            Context.Abort();
            return;
        }

        if (Context.User!.IsInRole("Admin"))
            await Groups.AddToGroupAsync(Context.ConnectionId, DeliveryHubGroups.Admins);
        if (Context.User.IsInRole("Shipper"))
            await Groups.AddToGroupAsync(Context.ConnectionId, DeliveryHubGroups.Shipper(userId));
        if (Context.User.IsInRole("Customer"))
            await Groups.AddToGroupAsync(Context.ConnectionId, DeliveryHubGroups.Customer(userId));

        await base.OnConnectedAsync();
    }
}

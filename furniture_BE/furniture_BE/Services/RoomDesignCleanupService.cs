using furniture_BE.Backend.Data;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Services;

public class RoomDesignCleanupService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<RoomDesignCleanupService> _logger;

    public RoomDesignCleanupService(IServiceScopeFactory scopeFactory, ILogger<RoomDesignCleanupService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await CleanupAsync(stoppingToken);
        using var timer = new PeriodicTimer(TimeSpan.FromHours(1));
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            await CleanupAsync(stoppingToken);
        }
    }

    private async Task CleanupAsync(CancellationToken cancellationToken)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var storage = scope.ServiceProvider.GetRequiredService<RoomDesignStorage>();
            var expired = await db.RoomDesigns
                .Where(d => d.ExpiresAt != null && d.ExpiresAt <= DateTime.UtcNow)
                .ToListAsync(cancellationToken);

            foreach (var design in expired)
            {
                storage.DeleteFiles(design);
            }

            if (expired.Count > 0)
            {
                db.RoomDesigns.RemoveRange(expired);
                await db.SaveChangesAsync(cancellationToken);
            }
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Không thể dọn các phối cảnh đã hết hạn.");
        }
    }
}

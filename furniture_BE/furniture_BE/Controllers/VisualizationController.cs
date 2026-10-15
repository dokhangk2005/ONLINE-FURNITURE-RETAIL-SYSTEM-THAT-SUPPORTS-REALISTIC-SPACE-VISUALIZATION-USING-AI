using System.Collections.Concurrent;
using furniture_BE.Backend.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using furniture_BE.Services;

namespace furniture_BE.Controllers;

[ApiController]
[Route("api/visualization")]
[AllowAnonymous]
public class VisualizationController : ControllerBase
{
    private static readonly ConcurrentDictionary<int, SemaphoreSlim> ImageLocks = new();
    private readonly AppDbContext _db;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;
    private readonly ProductImageStorage _productImageStorage;

    public VisualizationController(
        AppDbContext db,
        IHttpClientFactory httpClientFactory,
        IWebHostEnvironment environment,
        IConfiguration configuration,
        ProductImageStorage productImageStorage)
    {
        _db = db;
        _httpClientFactory = httpClientFactory;
        _environment = environment;
        _configuration = configuration;
        _productImageStorage = productImageStorage;
    }

    [HttpPost("products/{imageId:int}/remove-background")]
    public async Task<IActionResult> RemoveProductBackground(int imageId, CancellationToken cancellationToken)
    {
        var productImage = await _db.ProductImages.AsNoTracking().FirstOrDefaultAsync(i => i.ImageId == imageId, cancellationToken);
        if (productImage == null)
        {
            return NotFound(new { Message = "Không tìm thấy ảnh sản phẩm." });
        }

        var outputPath = GetProcessedPath(imageId);
        if (System.IO.File.Exists(outputPath))
        {
            return Ok(ResponseFor(imageId, fromCache: true));
        }

        var imageLock = ImageLocks.GetOrAdd(imageId, _ => new SemaphoreSlim(1, 1));
        await imageLock.WaitAsync(cancellationToken);
        try
        {
            if (System.IO.File.Exists(outputPath))
            {
                return Ok(ResponseFor(imageId, fromCache: true));
            }

            var (sourceBytes, fileName, contentType) = await ReadSourceImageAsync(productImage.ImageUrl, cancellationToken);
            if (sourceBytes.Length > 15 * 1024 * 1024)
            {
                return BadRequest(new { Message = "Ảnh sản phẩm vượt quá giới hạn xử lý 15 MB." });
            }

            using var form = new MultipartFormDataContent();
            using var fileContent = new ByteArrayContent(sourceBytes);
            fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(contentType);
            form.Add(fileContent, "file", fileName);

            var client = _httpClientFactory.CreateClient("BackgroundRemoval");
            var serviceUrl = (_configuration["AiServices:BackgroundRemovalUrl"] ?? "http://127.0.0.1:8001").TrimEnd('/');
            using var response = await client.PostAsync($"{serviceUrl}/remove-background", form, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                var detail = await response.Content.ReadAsStringAsync(cancellationToken);
                return StatusCode(503, new { Message = "Dịch vụ AI chưa xử lý được ảnh này.", Detail = detail });
            }

            var processedBytes = await response.Content.ReadAsByteArrayAsync(cancellationToken);
            if (processedBytes.Length == 0)
            {
                return StatusCode(503, new { Message = "Dịch vụ AI trả về ảnh rỗng." });
            }

            Directory.CreateDirectory(Path.GetDirectoryName(outputPath)!);
            await System.IO.File.WriteAllBytesAsync(outputPath, processedBytes, cancellationToken);
            return Ok(ResponseFor(imageId, fromCache: false));
        }
        catch (HttpRequestException)
        {
            return StatusCode(503, new { Message = "Dịch vụ AI xóa nền chưa hoạt động. Vui lòng khởi động AI service và thử lại." });
        }
        catch (TaskCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return StatusCode(504, new { Message = "AI xử lý ảnh quá thời gian cho phép." });
        }
        catch (FileNotFoundException ex)
        {
            return NotFound(new { Message = ex.Message });
        }
        finally
        {
            imageLock.Release();
        }
    }

    [HttpGet("products/{imageId:int}/transparent")]
    public IActionResult GetTransparentProductImage(int imageId)
    {
        var path = GetProcessedPath(imageId);
        return System.IO.File.Exists(path)
            ? PhysicalFile(path, "image/png", enableRangeProcessing: true)
            : NotFound(new { Message = "Ảnh sản phẩm chưa được AI xử lý." });
    }

    [HttpGet("health")]
    public async Task<IActionResult> Health(CancellationToken cancellationToken)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("BackgroundRemoval");
            var serviceUrl = (_configuration["AiServices:BackgroundRemovalUrl"] ?? "http://127.0.0.1:8001").TrimEnd('/');
            using var response = await client.GetAsync($"{serviceUrl}/health", cancellationToken);
            return Ok(new { Available = response.IsSuccessStatusCode });
        }
        catch
        {
            return Ok(new { Available = false });
        }
    }

    private object ResponseFor(int imageId, bool fromCache) => new
    {
        ImageId = imageId,
        TransparentImageUrl = $"/api/visualization/products/{imageId}/transparent",
        FromCache = fromCache
    };

    private string GetProcessedPath(int imageId) => Path.Combine(
        _environment.ContentRootPath,
        "Storage",
        "ProcessedProducts",
        $"product-image-{imageId}.png");

    private async Task<(byte[] Bytes, string FileName, string ContentType)> ReadSourceImageAsync(string imageUrl, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(imageUrl))
        {
            throw new FileNotFoundException("Sản phẩm chưa có ảnh để xử lý.");
        }

        if (Uri.TryCreate(imageUrl, UriKind.Absolute, out var remoteUri) && remoteUri.Scheme is "http" or "https")
        {
            var client = _httpClientFactory.CreateClient("BackgroundRemoval");
            using var response = await client.GetAsync(remoteUri, cancellationToken);
            response.EnsureSuccessStatusCode();
            var bytes = await response.Content.ReadAsByteArrayAsync(cancellationToken);
            var fileName = Path.GetFileName(remoteUri.LocalPath);
            var contentType = response.Content.Headers.ContentType?.MediaType ?? ContentTypeFor(fileName);
            return (bytes, string.IsNullOrWhiteSpace(fileName) ? "product.png" : fileName, contentType);
        }

        var localPath = _productImageStorage.ResolveLocalPath(imageUrl);
        if (localPath == null)
        {
            throw new FileNotFoundException("Không tìm thấy file ảnh sản phẩm trên máy chủ.");
        }
        return (await System.IO.File.ReadAllBytesAsync(localPath, cancellationToken), Path.GetFileName(localPath), ContentTypeFor(localPath));
    }

    private static string ContentTypeFor(string path) => Path.GetExtension(path).ToLowerInvariant() switch
    {
        ".jpg" or ".jpeg" => "image/jpeg",
        ".webp" => "image/webp",
        ".gif" => "image/gif",
        _ => "image/png"
    };
}

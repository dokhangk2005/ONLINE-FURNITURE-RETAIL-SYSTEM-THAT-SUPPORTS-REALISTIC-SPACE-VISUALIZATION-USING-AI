using System.Collections.Concurrent;
using System.IO.Compression;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.Extensions;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers;

[ApiController]
[Route("api/room-designs")]
public class RoomDesignsController : ControllerBase
{
    private const long MaxImageBytes = 10 * 1024 * 1024;
    private const long MaxAnalysisArchiveBytes = 40 * 1024 * 1024;
    private const long MaxHarmonizationImageBytes = 16 * 1024 * 1024;
    private static readonly ConcurrentDictionary<Guid, SemaphoreSlim> AnalysisLocks = new();
    private static readonly ConcurrentDictionary<string, SemaphoreSlim> HarmonizationLocks = new();
    private readonly AppDbContext _db;
    private readonly RoomDesignStorage _storage;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;
    private readonly ImageHarmonizationService _imageHarmonizer;
    private readonly ProductImageStorage _productImageStorage;

    public RoomDesignsController(
        AppDbContext db,
        RoomDesignStorage storage,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration,
        IWebHostEnvironment environment,
        ImageHarmonizationService imageHarmonizer,
        ProductImageStorage productImageStorage)
    {
        _db = db;
        _storage = storage;
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
        _environment = environment;
        _imageHarmonizer = imageHarmonizer;
        _productImageStorage = productImageStorage;
    }

    [AllowAnonymous]
    [HttpGet("harmonization/status")]
    public IActionResult GetHarmonizationStatus() => Ok(new
    {
        Available = _imageHarmonizer.IsConfigured,
        _imageHarmonizer.Provider,
        _imageHarmonizer.Model,
        _imageHarmonizer.Quality,
        _imageHarmonizer.Size,
        MaxReferenceImages = 2,
        Message = _imageHarmonizer.IsConfigured
            ? "AI đã sẵn sàng tạo ảnh mới từ ảnh phòng và ảnh sản phẩm."
            : $"Tính năng AI tạo phối cảnh chưa được cấu hình {_imageHarmonizer.Provider} API key ở backend."
    });

    [HttpGet("{id:guid}/harmonized/{cacheKey}")]
    public async Task<IActionResult> GetHarmonizedImage(
        Guid id,
        string cacheKey,
        [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound();
        }

        string path;
        try
        {
            path = _storage.GetHarmonizedFilePath(id, cacheKey);
        }
        catch (ArgumentException)
        {
            return BadRequest(new { Message = "Mã ảnh AI không hợp lệ." });
        }

        return System.IO.File.Exists(path)
            ? PhysicalFileWithCache(path, DetectStoredImageContentType(path), immutable: true)
            : NotFound();
    }

    [HttpPost("{id:guid}/generate-preview")]
    [RequestSizeLimit(1024 * 1024)]
    public async Task<IActionResult> GeneratePreview(
        Guid id,
        [FromQuery] string? accessToken,
        [FromForm] int? productImageId,
        [FromForm] string? productName,
        [FromForm] string? variantLabel,
        [FromForm] string? productImageIdsJson,
        [FromForm] string? productNamesJson,
        [FromForm] string? variantLabelsJson,
        [FromForm] string? placementPrompt)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." });
        }
        if (!_imageHarmonizer.IsConfigured)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new
            {
                Code = "AI_PROVIDER_NOT_CONFIGURED",
                Message = $"Tính năng AI tạo phối cảnh chưa được cấu hình {_imageHarmonizer.Provider} API key ở backend."
            });
        }

        List<int> productImageIds;
        List<string> productNames;
        List<string> variantLabels;
        try
        {
            productImageIds = string.IsNullOrWhiteSpace(productImageIdsJson)
                ? productImageId.HasValue ? [productImageId.Value] : []
                : JsonSerializer.Deserialize<List<int>>(productImageIdsJson) ?? [];
            productNames = string.IsNullOrWhiteSpace(productNamesJson)
                ? [productName ?? "Sản phẩm nội thất"]
                : JsonSerializer.Deserialize<List<string>>(productNamesJson) ?? [];
            variantLabels = string.IsNullOrWhiteSpace(variantLabelsJson)
                ? [variantLabel ?? "Mặc định"]
                : JsonSerializer.Deserialize<List<string>>(variantLabelsJson) ?? [];
        }
        catch (JsonException)
        {
            return BadRequest(new { Message = "Danh sách sản phẩm không hợp lệ." });
        }

        if (productImageIds.Count is < 1 or > 5 ||
            productNames.Count != productImageIds.Count ||
            variantLabels.Count != productImageIds.Count)
        {
            return BadRequest(new { Message = "Yêu cầu phải có từ 1 đến 5 sản phẩm hợp lệ." });
        }

        var productImagesById = await _db.ProductImages
            .AsNoTracking()
            .Where(image => productImageIds.Contains(image.ImageId))
            .ToDictionaryAsync(image => image.ImageId, HttpContext.RequestAborted);
        if (productImagesById.Count != productImageIds.Distinct().Count())
        {
            return NotFound(new { Message = "Không tìm thấy một hoặc nhiều ảnh sản phẩm." });
        }
        if (string.IsNullOrWhiteSpace(design.RoomImagePath) || !System.IO.File.Exists(design.RoomImagePath))
        {
            return NotFound(new { Message = "Không tìm thấy ảnh phòng gốc." });
        }

        var roomBytes = await System.IO.File.ReadAllBytesAsync(design.RoomImagePath, HttpContext.RequestAborted);
        var normalizedPrompt = (placementPrompt ?? string.Empty).Trim();
        normalizedPrompt = normalizedPrompt[..Math.Min(normalizedPrompt.Length, 500)];
        var products = new List<HarmonizationProductInput>(productImageIds.Count);
        for (var index = 0; index < productImageIds.Count; index++)
        {
            var imageId = productImageIds[index];
            var productImage = productImagesById[imageId];
            byte[] productBytes;
            try
            {
                productBytes = await ReadProductImageBytesAsync(
                    imageId,
                    productImage.ImageUrl,
                    HttpContext.RequestAborted);
            }
            catch (FileNotFoundException exception)
            {
                return NotFound(new { Message = exception.Message });
            }
            catch (HttpRequestException)
            {
                return StatusCode(StatusCodes.Status502BadGateway, new
                {
                    Message = "Không tải được ảnh sản phẩm từ nguồn lưu trữ."
                });
            }
            if (productBytes.Length == 0 || productBytes.Length > MaxHarmonizationImageBytes)
            {
                return BadRequest(new { Message = "Ảnh sản phẩm không hợp lệ hoặc vượt quá 16 MB." });
            }

            var normalizedName = productNames[index].Trim();
            var normalizedVariant = variantLabels[index].Trim();
            normalizedName = normalizedName[..Math.Min(normalizedName.Length, 160)];
            normalizedVariant = normalizedVariant[..Math.Min(normalizedVariant.Length, 160)];
            products.Add(new HarmonizationProductInput(
                productBytes,
                string.IsNullOrWhiteSpace(normalizedName) ? "Sản phẩm nội thất" : normalizedName,
                string.IsNullOrWhiteSpace(normalizedVariant) ? "Mặc định" : normalizedVariant));
        }

        var cacheKey = BuildGenerationCacheKey(
            roomBytes,
            products,
            normalizedPrompt);
        var outputPath = _storage.GetHarmonizedFilePath(id, cacheKey);
        if (System.IO.File.Exists(outputPath))
        {
            return Ok(HarmonizationResponse(id, cacheKey, accessToken, fromCache: true));
        }

        var lockKey = $"{id:N}:{cacheKey}";
        var harmonizationLock = HarmonizationLocks.GetOrAdd(lockKey, _ => new SemaphoreSlim(1, 1));
        await harmonizationLock.WaitAsync(HttpContext.RequestAborted);
        try
        {
            if (System.IO.File.Exists(outputPath))
            {
                return Ok(HarmonizationResponse(id, cacheKey, accessToken, fromCache: true));
            }

            var output = await _imageHarmonizer.GenerateRoomPreviewAsync(
                roomBytes,
                products,
                normalizedPrompt,
                HttpContext.RequestAborted);
            await System.IO.File.WriteAllBytesAsync(outputPath, output, HttpContext.RequestAborted);
            return Ok(HarmonizationResponse(id, cacheKey, accessToken, fromCache: false));
        }
        catch (ImageHarmonizationException exception)
        {
            return StatusCode((int)exception.StatusCode, new
            {
                exception.Code,
                exception.Message,
                exception.RequestId
            });
        }
        catch (HttpRequestException)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new
            {
                Code = "AI_PROVIDER_UNAVAILABLE",
                Message = "Không kết nối được dịch vụ tạo ảnh AI."
            });
        }
        catch (TaskCanceledException) when (!HttpContext.RequestAborted.IsCancellationRequested)
        {
            return StatusCode(StatusCodes.Status504GatewayTimeout, new
            {
                Code = "AI_PROVIDER_TIMEOUT",
                Message = "AI xử lý quá thời gian. Vui lòng thử lại."
            });
        }
        finally
        {
            harmonizationLock.Release();
        }
    }

    [HttpPost]
    [RequestSizeLimit(MaxImageBytes + 1024 * 1024)]
    public async Task<IActionResult> Create([FromForm] IFormFile? roomImage, [FromForm] string? title)
    {
        var (validationError, detectedExtension) = await ValidateImageAsync(roomImage);
        if (validationError != null)
        {
            return BadRequest(new { Message = validationError });
        }
        var validRoomImage = roomImage!;

        var userId = CurrentUserId();
        var accessToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32)).ToLowerInvariant();
        var design = new RoomDesign
        {
            UserId = userId,
            Title = string.IsNullOrWhiteSpace(title) ? "Không gian của tôi" : title.Trim()[..Math.Min(title.Trim().Length, 120)],
            AccessTokenHash = HashToken(accessToken),
            ExpiresAt = userId == null ? DateTime.UtcNow.AddHours(24) : null
        };

        var imagePath = _storage.CreateFilePath(design.RoomDesignId, "room", detectedExtension!);
        await using (var output = System.IO.File.Create(imagePath))
        {
            await validRoomImage.CopyToAsync(output);
        }

        design.RoomImagePath = imagePath;
        _db.RoomDesigns.Add(design);
        await _db.SaveChangesAsync();

        return Ok(ToResponse(design, accessToken));
    }

    [HttpGet("mine")]
    [Authorize]
    public async Task<IActionResult> GetMine()
    {
        var userId = User.UserId();
        var designs = await _db.RoomDesigns
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.UpdatedAt)
            .ToListAsync();
        return Ok(designs.Select(d => ToResponse(d, null)));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        return design == null ? NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." }) : Ok(ToResponse(design, accessToken));
    }

    [HttpGet("{id:guid}/room")]
    public async Task<IActionResult> GetRoomImage(Guid id, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null || !System.IO.File.Exists(design.RoomImagePath))
        {
            return NotFound();
        }

        return PhysicalFileWithCache(
            design.RoomImagePath,
            ContentTypeFor(design.RoomImagePath),
            immutable: true);
    }

    [HttpGet("{id:guid}/preview")]
    public async Task<IActionResult> GetPreview(Guid id, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null || string.IsNullOrWhiteSpace(design.PreviewImagePath) || !System.IO.File.Exists(design.PreviewImagePath))
        {
            return NotFound();
        }

        return PhysicalFileWithCache(design.PreviewImagePath, "image/png", immutable: false);
    }

    [HttpGet("{id:guid}/analysis")]
    public async Task<IActionResult> GetAnalysis(Guid id, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." });
        }

        var metadata = await ReadAnalysisMetadataAsync(id);
        Response.Headers["X-Scene-Cache"] = metadata == null ? "MISS" : "HIT";
        return metadata == null
            ? NotFound(new { Message = "Phối cảnh chưa được phân tích không gian." })
            : Ok(ToAnalysisResponse(id, metadata, cached: true));
    }

    [HttpGet("{id:guid}/analysis/{kind}")]
    public async Task<IActionResult> GetAnalysisImage(Guid id, string kind, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound();
        }

        var fileName = kind.ToLowerInvariant() switch
        {
            "depth" => "depth.png",
            "floor" => "floor-mask.png",
            "wall" => "wall-mask.png",
            "overlay" => "overlay.png",
            "occlusion-mask" => "occlusion-mask.png",
            "foreground" => "foreground.png",
            _ => null
        };
        if (fileName == null)
        {
            return BadRequest(new { Message = "Lớp phân tích không hợp lệ." });
        }

        var path = _storage.GetAnalysisFilePath(id, fileName);
        return System.IO.File.Exists(path)
            ? PhysicalFileWithCache(path, "image/png", immutable: false)
            : NotFound();
    }

    [HttpPost("{id:guid}/analyze")]
    [RequestSizeLimit(MaxAnalysisArchiveBytes)]
    public async Task<IActionResult> AnalyzeRoom(
        Guid id,
        [FromQuery] string? accessToken,
        [FromQuery] bool force = false)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null || !System.IO.File.Exists(design.RoomImagePath))
        {
            return NotFound(new { Message = "Không tìm thấy ảnh phòng hoặc bạn không có quyền truy cập." });
        }

        var analysisLock = AnalysisLocks.GetOrAdd(id, _ => new SemaphoreSlim(1, 1));
        await analysisLock.WaitAsync(HttpContext.RequestAborted);
        try
        {
            if (!force)
            {
                var cachedMetadata = await ReadAnalysisMetadataAsync(id);
                if (cachedMetadata != null && cachedMetadata.Supports2D && AnalysisFilesExist(id))
                {
                    Response.Headers["X-Scene-Cache"] = "HIT";
                    return Ok(ToAnalysisResponse(id, cachedMetadata, cached: true));
                }
            }

            var endpoint = _configuration["AiServices:SceneAnalysisUrl"];
            if (string.IsNullOrWhiteSpace(endpoint))
            {
                return StatusCode(503, new { Message = "AI phân tích không gian chưa được cấu hình." });
            }

            using var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
            using var multipart = new MultipartFormDataContent();
            await using var roomStream = System.IO.File.OpenRead(design.RoomImagePath);
            using var imageContent = new StreamContent(roomStream);
            imageContent.Headers.ContentType = new MediaTypeHeaderValue(ContentTypeFor(design.RoomImagePath));
            multipart.Add(imageContent, "file", Path.GetFileName(design.RoomImagePath));
            request.Content = multipart;

            var client = _httpClientFactory.CreateClient("SceneAnalysis");
            using var response = await client.SendAsync(
                request,
                HttpCompletionOption.ResponseHeadersRead,
                HttpContext.RequestAborted);
            if (!response.IsSuccessStatusCode)
            {
                var detail = await response.Content.ReadAsStringAsync(HttpContext.RequestAborted);
                return StatusCode(502, new
                {
                    Message = "AI không thể phân tích ảnh phòng.",
                    Detail = detail,
                    AiStatus = (int)response.StatusCode
                });
            }

            await using var archiveStream = await response.Content.ReadAsStreamAsync(HttpContext.RequestAborted);
            var metadata = await SaveAnalysisArchiveAsync(id, archiveStream, HttpContext.RequestAborted);
            design.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync(HttpContext.RequestAborted);
            Response.Headers["X-Scene-Cache"] = "MISS";
            return Ok(ToAnalysisResponse(id, metadata, cached: false));
        }
        catch (InvalidDataException exc)
        {
            return StatusCode(502, new { Message = "Kết quả AI không hợp lệ.", Detail = exc.Message });
        }
        catch (HttpRequestException exc)
        {
            return StatusCode(503, new { Message = "Không kết nối được AI phân tích không gian.", Detail = exc.Message });
        }
        catch (TaskCanceledException) when (!HttpContext.RequestAborted.IsCancellationRequested)
        {
            return StatusCode(504, new { Message = "AI phân tích không gian phản hồi quá thời gian." });
        }
        finally
        {
            analysisLock.Release();
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromQuery] string? accessToken, [FromBody] SaveRoomDesignRequest request)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." });
        }

        if (request.Items.ValueKind != JsonValueKind.Array)
        {
            return BadRequest(new { Message = "Danh sách sản phẩm trong phối cảnh không hợp lệ." });
        }
        if (request.Items.GetArrayLength() > 30)
        {
            return BadRequest(new { Message = "Mỗi phối cảnh chỉ được chứa tối đa 30 sản phẩm." });
        }

        var occlusionJson = "[]";
        if (request.OcclusionEdits.ValueKind != JsonValueKind.Undefined &&
            request.OcclusionEdits.ValueKind != JsonValueKind.Null)
        {
            if (request.OcclusionEdits.ValueKind != JsonValueKind.Array)
            {
                return BadRequest(new { Message = "Dữ liệu chỉnh mask che khuất không hợp lệ." });
            }
            if (request.OcclusionEdits.GetArrayLength() > 2500)
            {
                return BadRequest(new { Message = "Mask chỉ được chứa tối đa 2500 điểm chỉnh sửa." });
            }
            occlusionJson = request.OcclusionEdits.GetRawText();
        }

        var sceneJson = $"{{\"items\":{request.Items.GetRawText()},\"occlusionEdits\":{occlusionJson}}}";
        if (Encoding.UTF8.GetByteCount(sceneJson) > 512 * 1024)
        {
            return BadRequest(new { Message = "Dữ liệu phối cảnh quá lớn." });
        }

        if (!string.IsNullOrWhiteSpace(request.Title))
        {
            var normalizedTitle = request.Title.Trim();
            design.Title = normalizedTitle[..Math.Min(normalizedTitle.Length, 120)];
        }
        design.SceneJson = sceneJson;
        design.UpdatedAt = DateTime.UtcNow;

        var currentUserId = CurrentUserId();
        if (design.UserId == null && currentUserId != null)
        {
            design.UserId = currentUserId;
            design.ExpiresAt = null;
        }

        await _db.SaveChangesAsync();
        return Ok(ToResponse(design, accessToken));
    }

    [HttpPost("{id:guid}/preview")]
    [RequestSizeLimit(MaxImageBytes + 1024 * 1024)]
    public async Task<IActionResult> SavePreview(Guid id, [FromQuery] string? accessToken, [FromForm] IFormFile previewImage)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." });
        }
        if (previewImage.Length == 0 || previewImage.Length > MaxImageBytes ||
            !string.Equals(previewImage.ContentType, "image/png", StringComparison.OrdinalIgnoreCase) ||
            !await HasExpectedSignatureAsync(previewImage, ".png"))
        {
            return BadRequest(new { Message = "Ảnh kết quả phải là PNG và không vượt quá 10 MB." });
        }

        if (!string.IsNullOrWhiteSpace(design.PreviewImagePath) && System.IO.File.Exists(design.PreviewImagePath))
        {
            System.IO.File.Delete(design.PreviewImagePath);
        }

        var previewPath = _storage.CreateFilePath(design.RoomDesignId, "preview", ".png");
        await using (var output = System.IO.File.Create(previewPath))
        {
            await previewImage.CopyToAsync(output);
        }
        design.PreviewImagePath = previewPath;
        design.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(new { PreviewImageUrl = $"/api/room-designs/{design.RoomDesignId}/preview" });
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, [FromQuery] string? accessToken)
    {
        var design = await FindAccessibleAsync(id, accessToken);
        if (design == null)
        {
            return NotFound(new { Message = "Không tìm thấy phối cảnh hoặc bạn không có quyền truy cập." });
        }

        _storage.DeleteFiles(design);
        _db.RoomDesigns.Remove(design);
        await _db.SaveChangesAsync();
        return Ok(new { Message = "Đã xóa phối cảnh." });
    }

    private async Task<RoomDesign?> FindAccessibleAsync(Guid id, string? accessToken)
    {
        var design = await _db.RoomDesigns.FirstOrDefaultAsync(d => d.RoomDesignId == id);
        if (design == null || (design.ExpiresAt != null && design.ExpiresAt <= DateTime.UtcNow))
        {
            return null;
        }

        var userId = CurrentUserId();
        if (userId != null && design.UserId == userId)
        {
            return design;
        }

        return TokenMatches(design.AccessTokenHash, accessToken) ? design : null;
    }

    private bool AnalysisFilesExist(Guid id)
        => new[]
            {
                "depth.png", "floor-mask.png", "wall-mask.png", "overlay.png",
                "occlusion-mask.png", "foreground.png"
            }
            .All(name => System.IO.File.Exists(_storage.GetAnalysisFilePath(id, name)));

    private async Task<SceneAnalysisMetadata?> ReadAnalysisMetadataAsync(Guid id)
    {
        var path = _storage.GetAnalysisFilePath(id, "metadata.json");
        if (!System.IO.File.Exists(path))
        {
            return null;
        }

        try
        {
            await using var stream = System.IO.File.OpenRead(path);
            return await JsonSerializer.DeserializeAsync<SceneAnalysisMetadata>(stream);
        }
        catch (JsonException)
        {
            return null;
        }
    }

    private async Task<SceneAnalysisMetadata> SaveAnalysisArchiveAsync(
        Guid id,
        Stream stream,
        CancellationToken cancellationToken)
    {
        using var boundedStream = new MemoryStream();
        var buffer = new byte[81920];
        long totalRead = 0;
        int read;
        while ((read = await stream.ReadAsync(buffer, cancellationToken)) > 0)
        {
            totalRead += read;
            if (totalRead > MaxAnalysisArchiveBytes)
            {
                throw new InvalidDataException("Gói kết quả vượt quá 40 MB.");
            }
            await boundedStream.WriteAsync(buffer.AsMemory(0, read), cancellationToken);
        }
        boundedStream.Position = 0;

        using var archive = new ZipArchive(boundedStream, ZipArchiveMode.Read, leaveOpen: false);
        var expectedImages = new[]
        {
            "depth.png", "floor-mask.png", "wall-mask.png", "overlay.png",
            "occlusion-mask.png", "foreground.png"
        };
        var metadataEntry = archive.GetEntry("metadata.json")
            ?? throw new InvalidDataException("Thiếu metadata.json.");
        if (metadataEntry.Length > 64 * 1024)
        {
            throw new InvalidDataException("Metadata quá lớn.");
        }

        SceneAnalysisMetadata metadata;
        await using (var metadataStream = metadataEntry.Open())
        {
            metadata = await JsonSerializer.DeserializeAsync<SceneAnalysisMetadata>(metadataStream, cancellationToken: cancellationToken)
                ?? throw new InvalidDataException("Không đọc được metadata.");
        }
        metadata.AnalyzedAt = DateTime.UtcNow;

        foreach (var fileName in expectedImages)
        {
            var entry = archive.GetEntry(fileName)
                ?? throw new InvalidDataException($"Thiếu {fileName}.");
            if (entry.Length <= 8 || entry.Length > 15 * 1024 * 1024)
            {
                throw new InvalidDataException($"Kích thước {fileName} không hợp lệ.");
            }

            await using var entryStream = entry.Open();
            using var imageBuffer = new MemoryStream((int)entry.Length);
            await entryStream.CopyToAsync(imageBuffer, cancellationToken);
            var bytes = imageBuffer.ToArray();
            if (!bytes.AsSpan(0, 8).SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }))
            {
                throw new InvalidDataException($"{fileName} không phải PNG.");
            }
            await System.IO.File.WriteAllBytesAsync(
                _storage.GetAnalysisFilePath(id, fileName),
                bytes,
                cancellationToken);
        }

        var jsonOptions = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
        await System.IO.File.WriteAllTextAsync(
            _storage.GetAnalysisFilePath(id, "metadata.json"),
            JsonSerializer.Serialize(metadata, jsonOptions),
            cancellationToken);
        return metadata;
    }

    private static object ToAnalysisResponse(Guid id, SceneAnalysisMetadata metadata, bool cached) => new
    {
        DesignId = id,
        metadata.ModelVersion,
        metadata.Width,
        metadata.Height,
        metadata.FloorCoverage,
        metadata.WallCoverage,
        metadata.DepthMeaning,
        metadata.DepthInferenceMs,
        metadata.SegmentationInferenceMs,
        metadata.ProcessingMs,
        metadata.AnalyzedAt,
        metadata.FloorPlane,
        metadata.WallPlane,
        metadata.DepthGrid,
        metadata.Lighting,
        metadata.OcclusionCoverage,
        Cached = cached,
        CacheAgeSeconds = cached
            ? Math.Max(0, (long)(DateTime.UtcNow - metadata.AnalyzedAt).TotalSeconds)
            : 0,
        DepthMapUrl = $"/api/room-designs/{id}/analysis/depth",
        FloorMaskUrl = $"/api/room-designs/{id}/analysis/floor",
        WallMaskUrl = $"/api/room-designs/{id}/analysis/wall",
        OverlayUrl = $"/api/room-designs/{id}/analysis/overlay",
        OcclusionMaskUrl = $"/api/room-designs/{id}/analysis/occlusion-mask",
        ForegroundUrl = $"/api/room-designs/{id}/analysis/foreground"
    };

    private int? CurrentUserId()
    {
        if (User.Identity?.IsAuthenticated != true)
        {
            return null;
        }
        var id = User.UserId();
        return id > 0 ? id : null;
    }

    private object ToResponse(RoomDesign design, string? accessToken) => new
    {
        design.RoomDesignId,
        design.Title,
        design.SceneJson,
        design.CreatedAt,
        design.UpdatedAt,
        design.ExpiresAt,
        IsSaved = design.UserId != null,
        AccessToken = accessToken,
        RoomImageUrl = $"/api/room-designs/{design.RoomDesignId}/room",
        PreviewImageUrl = string.IsNullOrWhiteSpace(design.PreviewImagePath) ? null : $"/api/room-designs/{design.RoomDesignId}/preview"
    };

    private static async Task<(string? Error, string? Extension)> ValidateImageAsync(IFormFile? image)
    {
        if (image == null || image.Length == 0)
        {
            return ("Vui lòng chọn ảnh căn phòng.", null);
        }
        if (image.Length > MaxImageBytes)
        {
            return ("Ảnh căn phòng không được vượt quá 10 MB.", null);
        }
        var detectedExtension = await DetectImageExtensionAsync(image);
        return detectedExtension == null
            ? ("Nội dung file không phải ảnh JPG, PNG hoặc WEBP hợp lệ.", null)
            : (null, detectedExtension);
    }

    private async Task<byte[]> ReadProductImageBytesAsync(
        int imageId,
        string imageUrl,
        CancellationToken cancellationToken)
    {
        if (Uri.TryCreate(imageUrl, UriKind.Absolute, out var remoteUri) &&
            remoteUri.Scheme is "http" or "https")
        {
            try
            {
                var client = _httpClientFactory.CreateClient("OpenAIImages");
                using var response = await client.GetAsync(remoteUri, cancellationToken);
                if (response.IsSuccessStatusCode)
                {
                    var remoteBytes = await response.Content.ReadAsByteArrayAsync(cancellationToken);
                    if (IsSupportedImageBytes(remoteBytes)) return remoteBytes;
                }
            }
            catch (HttpRequestException)
            {
                // Thử ảnh PNG đã xóa nền trong cache phía dưới.
            }
        }
        else if (!string.IsNullOrWhiteSpace(imageUrl))
        {
            var localPath = _productImageStorage.ResolveLocalPath(imageUrl);
            if (localPath != null)
            {
                var localBytes = await System.IO.File.ReadAllBytesAsync(localPath, cancellationToken);
                if (IsSupportedImageBytes(localBytes)) return localBytes;
            }
        }

        var processedPath = Path.Combine(
            _environment.ContentRootPath,
            "Storage",
            "ProcessedProducts",
            $"product-image-{imageId}.png");
        if (System.IO.File.Exists(processedPath))
        {
            var processedBytes = await System.IO.File.ReadAllBytesAsync(processedPath, cancellationToken);
            if (IsSupportedImageBytes(processedBytes)) return processedBytes;
        }

        throw new FileNotFoundException(
            "Ảnh gốc không còn trên máy chủ và sản phẩm chưa có ảnh xóa nền trong cache.");
    }

    private static bool IsSupportedImageBytes(byte[] bytes)
        => (bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) ||
           (bytes.Length >= 8 && bytes.AsSpan(0, 8).SequenceEqual(
               new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A })) ||
           (bytes.Length >= 12 && bytes.AsSpan(0, 4).SequenceEqual("RIFF"u8) &&
            bytes.AsSpan(8, 4).SequenceEqual("WEBP"u8));

    private string BuildGenerationCacheKey(
        byte[] roomImage,
        IReadOnlyList<HarmonizationProductInput> products,
        string placementPrompt)
    {
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        AppendHashData(hash, Encoding.UTF8.GetBytes("direct-room-generation-v4-multi-product"));
        AppendHashData(hash, Encoding.UTF8.GetBytes(_imageHarmonizer.Provider));
        AppendHashData(hash, Encoding.UTF8.GetBytes(_imageHarmonizer.Model));
        AppendHashData(hash, Encoding.UTF8.GetBytes(_imageHarmonizer.Quality));
        AppendHashData(hash, Encoding.UTF8.GetBytes(_imageHarmonizer.Size));
        AppendHashData(hash, Encoding.UTF8.GetBytes(placementPrompt));
        AppendHashData(hash, roomImage);
        foreach (var product in products)
        {
            AppendHashData(hash, Encoding.UTF8.GetBytes(product.ProductName));
            AppendHashData(hash, Encoding.UTF8.GetBytes(product.VariantLabel));
            AppendHashData(hash, product.Image);
        }
        return Convert.ToHexString(hash.GetHashAndReset()).ToLowerInvariant();
    }

    private static void AppendHashData(IncrementalHash hash, byte[] data)
    {
        hash.AppendData(BitConverter.GetBytes(data.Length));
        hash.AppendData(data);
    }

    private object HarmonizationResponse(
        Guid id,
        string cacheKey,
        string? accessToken,
        bool fromCache)
    {
        var tokenQuery = string.IsNullOrWhiteSpace(accessToken)
            ? ""
            : $"?accessToken={Uri.EscapeDataString(accessToken)}";
        return new
        {
            ImageUrl = $"/api/room-designs/{id}/harmonized/{cacheKey}{tokenQuery}",
            FromCache = fromCache,
            _imageHarmonizer.Provider,
            _imageHarmonizer.Model,
            _imageHarmonizer.Quality,
            _imageHarmonizer.Size
        };
    }

    private static async Task<bool> HasExpectedSignatureAsync(IFormFile image, string extension)
        => string.Equals(await DetectImageExtensionAsync(image), extension, StringComparison.OrdinalIgnoreCase);

    private static async Task<string?> DetectImageExtensionAsync(IFormFile image)
    {
        var header = new byte[12];
        await using var stream = image.OpenReadStream();
        var read = await stream.ReadAsync(header);
        if (read >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
        {
            return ".jpg";
        }
        if (read >= 8 && header.AsSpan(0, 8).SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }))
        {
            return ".png";
        }
        if (read >= 12 && header.AsSpan(0, 4).SequenceEqual("RIFF"u8) &&
            header.AsSpan(8, 4).SequenceEqual("WEBP"u8))
        {
            return ".webp";
        }
        return null;
    }

    private static string NormalizeExtension(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return extension == ".jpeg" ? ".jpg" : extension;
    }

    private static string ContentTypeFor(string path) => Path.GetExtension(path).ToLowerInvariant() switch
    {
        ".png" => "image/png",
        ".webp" => "image/webp",
        _ => "image/jpeg"
    };

    private static string DetectStoredImageContentType(string path)
    {
        Span<byte> header = stackalloc byte[12];
        using var stream = System.IO.File.OpenRead(path);
        var read = stream.Read(header);
        if (read >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
        {
            return "image/jpeg";
        }
        if (read >= 12 && header[..4].SequenceEqual("RIFF"u8) && header.Slice(8, 4).SequenceEqual("WEBP"u8))
        {
            return "image/webp";
        }

        return "image/png";
    }

    private IActionResult PhysicalFileWithCache(string path, string contentType, bool immutable)
    {
        var file = new FileInfo(path);
        var etag = $"\"{file.Length:x}-{file.LastWriteTimeUtc.Ticks:x}\"";
        Response.Headers.ETag = etag;
        Response.Headers.CacheControl = immutable
            ? "private,max-age=31536000,immutable"
            : "private,no-cache";
        Response.Headers.Vary = "Authorization";

        var requestedEtags = Request.Headers.IfNoneMatch.ToString();
        if (requestedEtags.Split(',', StringSplitOptions.RemoveEmptyEntries)
            .Any(value => string.Equals(value.Trim(), etag, StringComparison.Ordinal)))
        {
            return StatusCode(StatusCodes.Status304NotModified);
        }
        return PhysicalFile(path, contentType, enableRangeProcessing: true);
    }

    private static string HashToken(string token) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token))).ToLowerInvariant();

    private static bool TokenMatches(string expectedHash, string? token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return false;
        }
        var actualHash = HashToken(token);
        return CryptographicOperations.FixedTimeEquals(Encoding.ASCII.GetBytes(expectedHash), Encoding.ASCII.GetBytes(actualHash));
    }
}

public class SaveRoomDesignRequest
{
    public string? Title { get; set; }
    public JsonElement Items { get; set; }
    public JsonElement OcclusionEdits { get; set; }
}

public class SceneAnalysisMetadata
{
    [JsonPropertyName("modelVersion")]
    public string ModelVersion { get; set; } = "";
    [JsonPropertyName("width")]
    public int Width { get; set; }
    [JsonPropertyName("height")]
    public int Height { get; set; }
    [JsonPropertyName("floorCoverage")]
    public double FloorCoverage { get; set; }
    [JsonPropertyName("wallCoverage")]
    public double WallCoverage { get; set; }
    [JsonPropertyName("depthMeaning")]
    public string DepthMeaning { get; set; } = "";
    [JsonPropertyName("depthInferenceMs")]
    public long DepthInferenceMs { get; set; }
    [JsonPropertyName("segmentationInferenceMs")]
    public long SegmentationInferenceMs { get; set; }
    [JsonPropertyName("processingMs")]
    public long ProcessingMs { get; set; }
    [JsonPropertyName("analyzedAt")]
    public DateTime AnalyzedAt { get; set; }
    [JsonPropertyName("floorPlane")]
    public ScenePlane? FloorPlane { get; set; }
    [JsonPropertyName("wallPlane")]
    public ScenePlane? WallPlane { get; set; }
    [JsonPropertyName("depthGrid")]
    public SceneDepthGrid? DepthGrid { get; set; }
    [JsonPropertyName("lighting")]
    public SceneLighting? Lighting { get; set; }
    [JsonPropertyName("occlusionCoverage")]
    public double? OcclusionCoverage { get; set; }
    [JsonIgnore]
    public bool Supports2B
        => (FloorPlane?.Points.Count == 4 || WallPlane?.Points.Count == 4) &&
           DepthGrid is { Width: > 0, Height: > 0 } &&
           DepthGrid.Values.Count == DepthGrid.Width * DepthGrid.Height;
    [JsonIgnore]
    public bool Supports2C
        => Supports2B &&
           Lighting?.Grid is { Width: > 0, Height: > 0 } &&
           Lighting.Grid.Values.Count == Lighting.Grid.Width * Lighting.Grid.Height;
    [JsonIgnore]
    public bool Supports2D => Supports2C && OcclusionCoverage is >= 0;
}

public class ScenePlane
{
    [JsonPropertyName("kind")]
    public string Kind { get; set; } = "";
    [JsonPropertyName("points")]
    public List<ScenePoint> Points { get; set; } = [];
    [JsonPropertyName("confidence")]
    public double Confidence { get; set; }
}

public class ScenePoint
{
    [JsonPropertyName("x")]
    public double X { get; set; }
    [JsonPropertyName("y")]
    public double Y { get; set; }
}

public class SceneDepthGrid
{
    [JsonPropertyName("width")]
    public int Width { get; set; }
    [JsonPropertyName("height")]
    public int Height { get; set; }
    [JsonPropertyName("values")]
    public List<int> Values { get; set; } = [];
}

public class SceneLighting
{
    [JsonPropertyName("ambientBrightness")]
    public double AmbientBrightness { get; set; }
    [JsonPropertyName("colorTemperature")]
    public double ColorTemperature { get; set; }
    [JsonPropertyName("contrast")]
    public double Contrast { get; set; }
    [JsonPropertyName("lightPosition")]
    public ScenePoint LightPosition { get; set; } = new();
    [JsonPropertyName("shadowDirection")]
    public ScenePoint ShadowDirection { get; set; } = new();
    [JsonPropertyName("shadowSoftness")]
    public double ShadowSoftness { get; set; }
    [JsonPropertyName("confidence")]
    public double Confidence { get; set; }
    [JsonPropertyName("grid")]
    public SceneDepthGrid Grid { get; set; } = new();
}

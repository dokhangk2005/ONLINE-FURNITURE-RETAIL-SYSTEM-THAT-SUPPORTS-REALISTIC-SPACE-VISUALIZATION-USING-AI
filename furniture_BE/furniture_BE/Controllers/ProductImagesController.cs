using furniture_BE.Backend.Data;
using furniture_BE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers
{
    [ApiController]
    [Route("uploads/products")]
    [AllowAnonymous]
    public class ProductImagesController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ProductImageStorage _storage;
        private readonly IConfiguration _configuration;

        public ProductImagesController(
            AppDbContext context,
            ProductImageStorage storage,
            IConfiguration configuration)
        {
            _context = context;
            _storage = storage;
            _configuration = configuration;
        }

        [HttpGet("by-id/{imageId:int}")]
        public async Task<IActionResult> GetImage(int imageId, CancellationToken cancellationToken)
        {
            var image = await _context.ProductImages
                .AsNoTracking()
                .FirstOrDefaultAsync(item => item.ImageId == imageId, cancellationToken);
            if (image == null)
                return NotFound(new { Message = "Không tìm thấy thông tin ảnh sản phẩm." });

            if (Uri.TryCreate(image.ImageUrl, UriKind.Absolute, out var remoteUri)
                && remoteUri.Scheme is "http" or "https")
            {
                return Redirect(remoteUri.ToString());
            }

            var sourcePath = _storage.ResolveLocalPath(image.ImageUrl);
            if (sourcePath != null)
                return PhysicalFile(sourcePath, ContentTypeFor(sourcePath), enableRangeProcessing: true);

            var frontendUrl = (_configuration["FrontendUrl"] ?? "http://127.0.0.1:8085").TrimEnd('/');
            return Redirect($"{frontendUrl}/assets/assets/images/products/product-.jpg");
        }

        private static string ContentTypeFor(string path) =>
            Path.GetExtension(path).ToLowerInvariant() switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".webp" => "image/webp",
                _ => "image/png"
            };
    }
}

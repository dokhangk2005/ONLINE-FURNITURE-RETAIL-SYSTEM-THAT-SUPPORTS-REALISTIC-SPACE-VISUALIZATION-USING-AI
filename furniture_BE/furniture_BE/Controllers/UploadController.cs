using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System;
using System.IO;
using System.Threading.Tasks;
using furniture_BE.Services;

namespace furniture_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Shipper")]
    public class UploadController : ControllerBase
    {
        private readonly ProductImageStorage _storage;

        public UploadController(ProductImageStorage storage)
        {
            _storage = storage;
        }

        [HttpPost("image")]
        [RequestSizeLimit(11 * 1024 * 1024)]
        public async Task<IActionResult> UploadImage(IFormFile? file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { Message = "File không hợp lệ hoặc rỗng." });
            if (file.Length > 10 * 1024 * 1024)
                return BadRequest(new { Message = "Ảnh không được vượt quá 10 MB." });

            var detectedExtension = await DetectImageExtensionAsync(file);
            if (detectedExtension == null)
                return BadRequest(new { Message = "Nội dung file không phải ảnh JPG, PNG hoặc WEBP hợp lệ." });

            try
            {
                await using var stream = file.OpenReadStream();
                var relativeUrl = await _storage.SaveAsync(
                    stream,
                    detectedExtension,
                    HttpContext.RequestAborted);
                return Ok(new { ImageUrl = relativeUrl });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = $"Lỗi upload: {ex.Message}" });
            }
        }

        private static async Task<string?> DetectImageExtensionAsync(IFormFile file)
        {
            var header = new byte[12];
            await using var stream = file.OpenReadStream();
            var read = await stream.ReadAsync(header);
            if (read >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
                return ".jpg";
            if (read >= 8 && header.AsSpan(0, 8).SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }))
                return ".png";
            if (read >= 12 && header.AsSpan(0, 4).SequenceEqual("RIFF"u8) &&
                header.AsSpan(8, 4).SequenceEqual("WEBP"u8))
                return ".webp";
            return null;
        }
    }
}

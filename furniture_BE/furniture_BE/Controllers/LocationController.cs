using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace furniture_BE.Controllers;

[ApiController, Route("api/[controller]"), Authorize]
public class LocationController : ControllerBase
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public LocationController(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    [HttpGet("suggest")]
    public Task<IActionResult> Suggest([FromQuery] string q, [FromQuery] string sessionToken) =>
        Proxy($"suggest?q={Uri.EscapeDataString(q.Trim())}&session_token={Uri.EscapeDataString(sessionToken)}&language=vi&limit=5&country=vn", q.Length >= 3);

    [HttpGet("retrieve/{mapboxId}")]
    public Task<IActionResult> Retrieve(string mapboxId, [FromQuery] string sessionToken) =>
        Proxy($"retrieve/{Uri.EscapeDataString(mapboxId)}?session_token={Uri.EscapeDataString(sessionToken)}&language=vi", !string.IsNullOrWhiteSpace(mapboxId));

    private async Task<IActionResult> Proxy(string pathAndQuery, bool valid)
    {
        if (!valid) return BadRequest(new { Message = "Yêu cầu tìm kiếm không hợp lệ." });
        var token = _configuration["Mapbox:AccessToken"];
        if (string.IsNullOrWhiteSpace(token)) return StatusCode(503, new { Message = "Dịch vụ gợi ý địa chỉ chưa được cấu hình." });

        var separator = pathAndQuery.Contains('?') ? "&" : "?";
        var url = $"https://api.mapbox.com/search/searchbox/v1/{pathAndQuery}{separator}access_token={Uri.EscapeDataString(token)}";
        using var response = await _httpClientFactory.CreateClient().GetAsync(url);
        var json = await response.Content.ReadAsStringAsync();
        return new ContentResult { StatusCode = (int)response.StatusCode, ContentType = "application/json", Content = json };
    }
}

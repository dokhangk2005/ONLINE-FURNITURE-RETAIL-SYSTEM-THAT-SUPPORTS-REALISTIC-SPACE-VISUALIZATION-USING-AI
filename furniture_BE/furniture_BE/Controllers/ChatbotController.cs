using System.Net;
using System.Text;
using System.Text.Json;
using furniture_BE.Backend.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers
{
    public class ChatRequestDto
    {
        public string Question { get; set; } = string.Empty;
    }

    public sealed record ChatCatalogProduct(
        int ProductId,
        string ProductName,
        decimal BasePrice,
        decimal DiscountPercent,
        bool IsDiscountActive,
        DateTime? DiscountStartAt,
        DateTime? DiscountEndAt,
        string? ProductCode,
        string? Description);

    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatbotController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly string _apiKey;
        private readonly string _model;
        private readonly string _baseUrl;
        private readonly string _openAiApiKey;
        private readonly string _openAiModel;
        private readonly string _openAiBaseUrl;
        private readonly ILogger<ChatbotController> _logger;

        public ChatbotController(
            AppDbContext context,
            IConfiguration configuration,
            IHttpClientFactory httpClientFactory,
            ILogger<ChatbotController> logger)
        {
            _context = context;
            _httpClientFactory = httpClientFactory;
            _apiKey = configuration["Gemini:ApiKey"] ?? string.Empty;
            _model = configuration["Gemini:ChatModel"] ?? "gemini-3.5-flash";
            _baseUrl = (configuration["Gemini:ChatBaseUrl"] ??
                        "https://generativelanguage.googleapis.com/v1beta").TrimEnd('/');
            _openAiApiKey = configuration["OpenAI:ApiKey"] ?? string.Empty;
            _openAiModel = configuration["OpenAI:ChatModel"] ?? "gpt-4.1-mini";
            _openAiBaseUrl = (configuration["OpenAI:BaseUrl"] ??
                              "https://api.openai.com/v1").TrimEnd('/');
            _logger = logger;
        }

        [HttpPost("ask")]
        public async Task<IActionResult> Ask([FromBody] ChatRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Question))
            {
                return BadRequest(new { message = "Vui lòng nhập nội dung câu hỏi!" });
            }

            string? openAiFallbackPrompt = null;
            IReadOnlyCollection<ChatCatalogProduct> products =
                Array.Empty<ChatCatalogProduct>();
            try
            {
                // RAG: Retrieve active product catalog from Database
                products = await _context.Products
                    .Where(p => !p.IsDeleted)
                    .OrderByDescending(p => p.CreatedAt)
                    .Take(100)
                    .Select(p => new ChatCatalogProduct(
                        p.ProductId,
                        p.ProductName,
                        p.BasePrice,
                        p.DiscountPercent,
                        p.IsDiscountActive,
                        p.DiscountStartAt,
                        p.DiscountEndAt,
                        p.ProductCode,
                        p.Description))
                    .ToListAsync();

                var catalogSummary = new StringBuilder();
                catalogSummary.AppendLine("IMPORTANT: Keep every recommended product name exactly as written in the catalog so the UI can make it clickable.");
                catalogSummary.AppendLine("Danh sách sản phẩm hiện đang mở bán chính thức tại shop My Furniture Store hôm nay:");
                foreach (var p in products)
                {
                    var now = DateTime.UtcNow;
                    var discounted = p.IsDiscountActive && p.DiscountPercent > 0
                        && (!p.DiscountStartAt.HasValue || p.DiscountStartAt.Value <= now)
                        && (!p.DiscountEndAt.HasValue || p.DiscountEndAt.Value >= now);
                    var effectivePrice = discounted
                        ? Math.Round(p.BasePrice * (100m - p.DiscountPercent) / 100m, 0)
                        : p.BasePrice;
                    var price = discounted
                        ? $"Giá gốc {p.BasePrice:N0} VNĐ, giảm {p.DiscountPercent:0.##}%, còn {effectivePrice:N0} VNĐ"
                        : $"Giá {p.BasePrice:N0} VNĐ";
                    catalogSummary.AppendLine($"- {p.ProductName} (Mã: {p.ProductCode}): {price}. Mô tả: {p.Description}");
                }

                // Construct System & Custom Instruction for Gemini
                string fullPrompt = $@"Bạn là Trợ lý AI Tư Vấn Nội Thất Thông Minh, Uyên Bác và Duyên Dáng của cửa hàng 'My Furniture Store'.
Nhiệm vụ của bạn là tư vấn nhiệt tình, lịch sự, chuyên nghiệp cho khách hàng về các mẫu nội thất, cách phối màu, bố trí không gian và phong thủy nhà ở.

{catalogSummary}

QUY TẮC TƯ VẤN BẮT BUỘC:
1. Trả lời bằng tiếng Việt chuẩn mực, duyên dáng, sử dụng các biểu tượng emoji tinh tế (✨, 🛋️, 🌟, 💡, 🔥...).
2. Khi khách hỏi tìm mua sản phẩm (sofa, bàn ghế, tủ giường...), HÃY ĐỐI CHIẾU với danh sách sản phẩm trên và ĐỀ XUẤT CHÍNH XÁC tên, mã sản phẩm và giá tiền. Mời khách hàng tìm tên món đồ trong thanh tìm kiếm hoặc chuyên mục để thêm vào giỏ hàng!
3. Nếu shop không có mặt hàng đúng 100% như khách cần, hãy giới thiệu sản phẩm tương tự trong danh sách, hoặc thông báo khách có thể vào trang Cá Nhân -> Trung Tâm Hỗ Trợ Q&A để gửi yêu cầu đặt gia công theo kích thước riêng.
4. Trình bày khúc chiết, mạch lạc bằng gạch đầu dòng, tổng độ dài dưới 350 từ để khách dễ đọc trên giao diện cửa sổ Chat mini.

CÂU Hỏi CỦA KHÁCH HÀNG: ""{request.Question}""
AI TRẢ LỜI:";
                openAiFallbackPrompt = fullPrompt;

                var requestBody = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new[]
                            {
                                new { text = fullPrompt }
                            }
                        }
                    },
                    generationConfig = new
                    {
                        temperature = 0.7,
                        maxOutputTokens = 800
                    }
                };

                if (string.IsNullOrWhiteSpace(_apiKey))
                {
                    var openAiReply = await TryAskOpenAiAsync(
                        fullPrompt,
                        HttpContext.RequestAborted);
                    if (!string.IsNullOrWhiteSpace(openAiReply))
                    {
                        return ChatSuccess(openAiReply, products, "OpenAI", true);
                    }

                    return StatusCode(503, new { message = "Chatbot chưa được cấu hình." });
                }
                string url = $"{_baseUrl}/models/{Uri.EscapeDataString(_model)}:generateContent";
                var jsonContent = JsonSerializer.Serialize(requestBody);
                var client = _httpClientFactory.CreateClient("GeminiChat");
                HttpStatusCode lastStatus = HttpStatusCode.ServiceUnavailable;
                string resJson = string.Empty;
                for (var attempt = 0; attempt < 4; attempt++)
                {
                    using var httpRequest = new HttpRequestMessage(HttpMethod.Post, url)
                    {
                        Content = new StringContent(jsonContent, Encoding.UTF8, "application/json")
                    };
                    httpRequest.Headers.TryAddWithoutValidation("x-goog-api-key", _apiKey);
                    using var response = await client.SendAsync(
                        httpRequest,
                        HttpCompletionOption.ResponseHeadersRead,
                        HttpContext.RequestAborted);
                    lastStatus = response.StatusCode;
                    resJson = await response.Content.ReadAsStringAsync(HttpContext.RequestAborted);
                    if (response.IsSuccessStatusCode)
                    {
                        break;
                    }
                    if (!IsTransient(response.StatusCode) || attempt == 3)
                    {
                        break;
                    }

                    var retryAfter = response.Headers.RetryAfter?.Delta;
                    var delay = retryAfter ?? TimeSpan.FromMilliseconds(
                        Math.Pow(2, attempt) * 700 + Random.Shared.Next(100, 450));
                    await Task.Delay(delay, HttpContext.RequestAborted);
                }

                if ((int)lastStatus is < 200 or >= 300)
                {
                    _logger.LogWarning(
                        "Gemini chatbot failed with HTTP {Status}; trying OpenAI fallback.",
                        (int)lastStatus);
                    var openAiReply = await TryAskOpenAiAsync(
                        fullPrompt,
                        HttpContext.RequestAborted);
                    if (!string.IsNullOrWhiteSpace(openAiReply))
                    {
                        return ChatSuccess(openAiReply, products, "OpenAI", true);
                    }

                    if (IsTransient(lastStatus))
                    {
                        return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                        {
                            code = "GEMINI_BUSY",
                            retryable = true,
                            message = "Gemini đang bận hoặc bị giới hạn tạm thời. Vui lòng thử lại sau."
                        });
                    }

                    return StatusCode((int)lastStatus, new
                    {
                        code = "GEMINI_REQUEST_FAILED",
                        retryable = false,
                        message = "Không thể gửi yêu cầu đến Gemini. Hãy kiểm tra API key và model cấu hình."
                    });
                }

                using var doc = JsonDocument.Parse(resJson);
                var root = doc.RootElement;
                string aiReply = "✨ Trợ lý AI đã ghi nhận thắc mắc của bạn nhưng hiện tại thư viện suy nghĩ chưa kịp phản hồi. Bạn hãy thử lại câu hỏi nhé!";

                if (root.TryGetProperty("candidates", out var candidates) && candidates.GetArrayLength() > 0)
                {
                    var firstCandidate = candidates[0];
                    if (firstCandidate.TryGetProperty("content", out var contentProp) &&
                        contentProp.TryGetProperty("parts", out var parts) &&
                        parts.GetArrayLength() > 0)
                    {
                        aiReply = parts[0].GetProperty("text").GetString() ?? aiReply;
                    }
                }

                return ChatSuccess(aiReply, products, "Gemini", false);
            }
            catch (OperationCanceledException) when (!HttpContext.RequestAborted.IsCancellationRequested)
            {
                var openAiReply = openAiFallbackPrompt is null
                    ? null
                    : await TryAskOpenAiAsync(
                        openAiFallbackPrompt,
                        HttpContext.RequestAborted);
                if (!string.IsNullOrWhiteSpace(openAiReply))
                {
                    return ChatSuccess(openAiReply, products, "OpenAI", true);
                }

                return StatusCode(StatusCodes.Status504GatewayTimeout, new
                {
                    code = "GEMINI_TIMEOUT",
                    retryable = true,
                    message = "Gemini phản hồi quá thời gian. Vui lòng thử lại."
                });
            }
            catch (Exception ex)
            {
                if (openAiFallbackPrompt is not null &&
                    !HttpContext.RequestAborted.IsCancellationRequested)
                {
                    var openAiReply = await TryAskOpenAiAsync(
                        openAiFallbackPrompt,
                        HttpContext.RequestAborted);
                    if (!string.IsNullOrWhiteSpace(openAiReply))
                    {
                        return ChatSuccess(openAiReply, products, "OpenAI", true);
                    }
                }

                return StatusCode(StatusCodes.Status503ServiceUnavailable, new
                {
                    code = "CHATBOT_UNAVAILABLE",
                    retryable = true,
                    message = $"Trợ lý AI tạm thời gián đoạn: {ex.Message}"
                });
            }
        }

        private static bool IsTransient(HttpStatusCode statusCode) =>
            statusCode == HttpStatusCode.RequestTimeout ||
            statusCode == HttpStatusCode.TooManyRequests ||
            (int)statusCode >= 500;

        private OkObjectResult ChatSuccess(
            string reply,
            IReadOnlyCollection<ChatCatalogProduct> catalog,
            string provider,
            bool fallback)
        {
            var productLinks = catalog
                .Where(product => reply.Contains(
                    product.ProductName,
                    StringComparison.OrdinalIgnoreCase))
                .OrderBy(product => reply.IndexOf(
                    product.ProductName,
                    StringComparison.OrdinalIgnoreCase))
                .Select(product => new
                {
                    productId = product.ProductId,
                    productName = product.ProductName
                })
                .ToList();

            return Ok(new { reply, provider, fallback, productLinks });
        }

        private async Task<string?> TryAskOpenAiAsync(
            string prompt,
            CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(_openAiApiKey))
            {
                _logger.LogWarning("OpenAI chatbot fallback is not configured.");
                return null;
            }

            var requestBody = new
            {
                model = _openAiModel,
                input = prompt,
                max_output_tokens = 1000
            };
            var jsonContent = JsonSerializer.Serialize(requestBody);
            var client = _httpClientFactory.CreateClient("OpenAIChat");
            var url = $"{_openAiBaseUrl}/responses";

            try
            {
                for (var attempt = 0; attempt < 3; attempt++)
                {
                    using var request = new HttpRequestMessage(HttpMethod.Post, url)
                    {
                        Content = new StringContent(jsonContent, Encoding.UTF8, "application/json")
                    };
                    request.Headers.TryAddWithoutValidation(
                        "Authorization",
                        $"Bearer {_openAiApiKey}");

                    using var response = await client.SendAsync(
                        request,
                        HttpCompletionOption.ResponseHeadersRead,
                        cancellationToken);
                    var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
                    if (response.IsSuccessStatusCode)
                    {
                        var reply = ExtractOpenAiText(responseJson);
                        if (!string.IsNullOrWhiteSpace(reply)) return reply;

                        _logger.LogWarning("OpenAI chatbot returned no output text.");
                        return null;
                    }

                    _logger.LogWarning(
                        "OpenAI chatbot fallback failed with HTTP {Status} on attempt {Attempt}.",
                        (int)response.StatusCode,
                        attempt + 1);
                    if (!IsTransient(response.StatusCode) || attempt == 2) return null;

                    var retryAfter = response.Headers.RetryAfter?.Delta;
                    var delay = retryAfter ?? TimeSpan.FromMilliseconds(
                        Math.Pow(2, attempt) * 600 + Random.Shared.Next(100, 350));
                    await Task.Delay(delay, cancellationToken);
                }
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "OpenAI chatbot fallback could not complete.");
            }

            return null;
        }

        private static string? ExtractOpenAiText(string responseJson)
        {
            using var document = JsonDocument.Parse(responseJson);
            if (!document.RootElement.TryGetProperty("output", out var output) ||
                output.ValueKind != JsonValueKind.Array)
            {
                return null;
            }

            var text = new StringBuilder();
            foreach (var item in output.EnumerateArray())
            {
                if (!item.TryGetProperty("content", out var content) ||
                    content.ValueKind != JsonValueKind.Array)
                {
                    continue;
                }

                foreach (var part in content.EnumerateArray())
                {
                    if (part.TryGetProperty("type", out var type) &&
                        type.GetString() == "output_text" &&
                        part.TryGetProperty("text", out var value))
                    {
                        text.Append(value.GetString());
                    }
                }
            }

            return text.Length == 0 ? null : text.ToString().Trim();
        }
    }
}

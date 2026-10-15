using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace furniture_BE.Services
{
    public enum ReviewModerationDecision
    {
        Allow,
        Block,
        NeedsReview
    }

    public sealed record ReviewModerationResult(
        ReviewModerationDecision Decision,
        string Reason);

    public class ReviewModerationService
    {
        private static readonly string[] VietnameseBlockedPhrases =
        {
            "địt mẹ", "đụ má", "đéo", "lồn", "cặc", "buồi",
            "con đĩ", "đồ chó", "óc chó", "súc vật"
        };

        private static readonly string[] LatinBlockedPhrases =
        {
            "dit me", "du ma", "fuck", "fucking", "bitch", "asshole", "motherfucker"
        };

        private static readonly string[] BlockingCategories =
        {
            "harassment", "harassment/threatening", "hate", "hate/threatening",
            "sexual", "sexual/minors", "violence/graphic"
        };

        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ReviewModerationService> _logger;

        public ReviewModerationService(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<ReviewModerationService> logger)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<ReviewModerationResult> ModerateAsync(
            string? comment,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(comment))
                return new(ReviewModerationDecision.Allow, "Không có nội dung chữ cần kiểm duyệt.");

            if (ContainsClearlyBlockedLanguage(comment))
                return new(ReviewModerationDecision.Block, "Phát hiện ngôn từ tục tĩu.");

            var apiKey = _configuration["OpenAI:ApiKey"];
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                _logger.LogWarning("OpenAI:ApiKey is not configured; review will require manual moderation.");
                return new(ReviewModerationDecision.NeedsReview, "Chưa cấu hình dịch vụ AI.");
            }

            try
            {
                var baseUrl = (_configuration["OpenAI:BaseUrl"] ?? "https://api.openai.com/v1").TrimEnd('/');
                var model = _configuration["OpenAI:ModerationModel"] ?? "omni-moderation-latest";
                using var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/moderations");
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                request.Content = JsonContent.Create(new { model, input = comment.Trim() });

                var client = _httpClientFactory.CreateClient("OpenAIModeration");
                using var response = await client.SendAsync(request, cancellationToken);
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning(
                        "OpenAI moderation returned HTTP {StatusCode}; review will require manual moderation.",
                        (int)response.StatusCode);
                    return new(ReviewModerationDecision.NeedsReview, "Dịch vụ AI tạm thời không khả dụng.");
                }

                await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
                using var json = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
                var results = json.RootElement.GetProperty("results");
                if (results.GetArrayLength() == 0)
                    return new(ReviewModerationDecision.NeedsReview, "AI không trả về kết quả kiểm duyệt.");

                var first = results[0];
                var flagged = first.TryGetProperty("flagged", out var flaggedElement)
                    && flaggedElement.GetBoolean();
                if (!flagged)
                    return new(ReviewModerationDecision.Allow, "AI xác nhận nội dung phù hợp.");

                if (first.TryGetProperty("categories", out var categories))
                {
                    foreach (var category in BlockingCategories)
                    {
                        if (categories.TryGetProperty(category, out var value) && value.GetBoolean())
                            return new(ReviewModerationDecision.Block, $"AI phát hiện nội dung không phù hợp: {category}.");
                    }
                }

                return new(ReviewModerationDecision.NeedsReview, "AI gắn cờ nội dung cần admin xem xét.");
            }
            catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
            {
                _logger.LogWarning("OpenAI moderation request timed out; review will require manual moderation.");
                return new(ReviewModerationDecision.NeedsReview, "Dịch vụ AI hết thời gian phản hồi.");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "OpenAI moderation failed; review will require manual moderation.");
                return new(ReviewModerationDecision.NeedsReview, "Không thể kiểm duyệt tự động.");
            }
        }

        private static bool ContainsClearlyBlockedLanguage(string text)
        {
            var normalized = Regex.Replace(text.ToLowerInvariant(), @"[^\p{L}\p{N}]+", " ").Trim();
            if (VietnameseBlockedPhrases.Any(phrase => ContainsWholePhrase(normalized, phrase)))
                return true;

            var withoutDiacritics = RemoveDiacritics(normalized);
            return LatinBlockedPhrases.Any(phrase => ContainsWholePhrase(withoutDiacritics, phrase));
        }

        private static bool ContainsWholePhrase(string text, string phrase) =>
            Regex.IsMatch(text, $@"(?:^|\s){Regex.Escape(phrase)}(?:$|\s)", RegexOptions.CultureInvariant);

        private static string RemoveDiacritics(string text)
        {
            var decomposed = text.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(decomposed.Length);
            foreach (var character in decomposed)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark)
                    builder.Append(character == 'đ' ? 'd' : character == 'Đ' ? 'D' : character);
            }
            return builder.ToString().Normalize(NormalizationForm.FormC);
        }
    }
}

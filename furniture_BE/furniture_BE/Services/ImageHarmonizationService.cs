using System.Net;

namespace furniture_BE.Services;

public interface IImageHarmonizationProvider
{
    string Provider { get; }
    bool IsConfigured { get; }
    string Model { get; }
    string Quality { get; }
    string Size { get; }

    Task<byte[]> GenerateRoomPreviewAsync(
        byte[] roomImage,
        IReadOnlyList<HarmonizationProductInput> products,
        string placementPrompt,
        CancellationToken cancellationToken);
}

public sealed record HarmonizationProductInput(
    byte[] Image,
    string ProductName,
    string VariantLabel);

public sealed class ImageHarmonizationService
{
    private readonly IConfiguration _configuration;
    private readonly OpenAiImageHarmonizationService _openAi;
    private readonly GeminiImageHarmonizationService _gemini;

    public ImageHarmonizationService(
        IConfiguration configuration,
        OpenAiImageHarmonizationService openAi,
        GeminiImageHarmonizationService gemini)
    {
        _configuration = configuration;
        _openAi = openAi;
        _gemini = gemini;
    }

    public string Provider => NormalizeProvider(_configuration["AIImageGeneration:Provider"]);
    public bool IsConfigured => SelectedProvider?.IsConfigured == true;
    public string Model => SelectedProvider?.Model ?? "unknown";
    public string Quality => SelectedProvider?.Quality ?? "unknown";
    public string Size => SelectedProvider?.Size ?? "unknown";

    public Task<byte[]> GenerateRoomPreviewAsync(
        byte[] roomImage,
        IReadOnlyList<HarmonizationProductInput> products,
        string placementPrompt,
        CancellationToken cancellationToken)
    {
        var provider = SelectedProvider;
        if (provider == null)
        {
            throw new ImageHarmonizationException(
                HttpStatusCode.ServiceUnavailable,
                "AI_PROVIDER_INVALID",
                $"Nhà cung cấp AI '{Provider}' không được hỗ trợ. Hãy chọn Gemini hoặc OpenAI.");
        }

        return provider.GenerateRoomPreviewAsync(
            roomImage,
            products,
            placementPrompt,
            cancellationToken);
    }

    private IImageHarmonizationProvider? SelectedProvider => Provider switch
    {
        "Gemini" => _gemini,
        "OpenAI" => _openAi,
        _ => null
    };

    private static string NormalizeProvider(string? provider)
    {
        if (string.Equals(provider, "OpenAI", StringComparison.OrdinalIgnoreCase))
        {
            return "OpenAI";
        }

        if (string.IsNullOrWhiteSpace(provider) ||
            string.Equals(provider, "Gemini", StringComparison.OrdinalIgnoreCase))
        {
            return "Gemini";
        }

        return provider.Trim();
    }
}

public sealed class ImageHarmonizationException : Exception
{
    public ImageHarmonizationException(
        HttpStatusCode statusCode,
        string code,
        string message,
        string? requestId = null,
        Exception? innerException = null)
        : base(message, innerException)
    {
        StatusCode = statusCode;
        Code = code;
        RequestId = requestId;
    }

    public HttpStatusCode StatusCode { get; }
    public string Code { get; }
    public string? RequestId { get; }
}

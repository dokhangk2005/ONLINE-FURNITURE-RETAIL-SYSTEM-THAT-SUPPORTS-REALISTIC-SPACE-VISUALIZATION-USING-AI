using furniture_BE.Backend.Models;

namespace furniture_BE.Services;

public class RoomDesignStorage
{
    private readonly string _root;

    public RoomDesignStorage(IWebHostEnvironment environment)
    {
        _root = Path.Combine(environment.ContentRootPath, "Storage", "RoomDesigns");
        Directory.CreateDirectory(_root);
    }

    public string GetDesignDirectory(Guid designId) => Path.Combine(_root, designId.ToString("N"));

    public string CreateFilePath(Guid designId, string prefix, string extension)
    {
        var directory = GetDesignDirectory(designId);
        Directory.CreateDirectory(directory);
        return Path.Combine(directory, $"{prefix}-{Guid.NewGuid():N}{extension}");
    }

    public string GetAnalysisFilePath(Guid designId, string fileName)
    {
        var allowedNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "metadata.json",
            "depth.png",
            "floor-mask.png",
            "wall-mask.png",
            "overlay.png",
            "occlusion-mask.png",
            "foreground.png"
        };
        if (!allowedNames.Contains(fileName))
        {
            throw new ArgumentException("Invalid room analysis file name.", nameof(fileName));
        }

        var directory = Path.Combine(GetDesignDirectory(designId), "analysis");
        Directory.CreateDirectory(directory);
        return Path.Combine(directory, fileName);
    }

    public string GetHarmonizedFilePath(Guid designId, string cacheKey)
    {
        if (cacheKey.Length != 64 || cacheKey.Any(character => !Uri.IsHexDigit(character)))
        {
            throw new ArgumentException("Invalid harmonized image cache key.", nameof(cacheKey));
        }

        var directory = Path.Combine(GetDesignDirectory(designId), "harmonized");
        Directory.CreateDirectory(directory);
        return Path.Combine(directory, $"{cacheKey.ToLowerInvariant()}.png");
    }

    public void DeleteFiles(RoomDesign design)
    {
        var directory = GetDesignDirectory(design.RoomDesignId);
        if (Directory.Exists(directory))
        {
            Directory.Delete(directory, recursive: true);
        }
    }
}

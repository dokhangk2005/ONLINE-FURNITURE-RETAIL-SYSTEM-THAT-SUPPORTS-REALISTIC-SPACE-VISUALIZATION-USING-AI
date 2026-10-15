namespace furniture_BE.Services
{
    public sealed class ProductImageStorage
    {
        public const string RequestPath = "/uploads/products";

        private readonly IWebHostEnvironment _environment;

        public ProductImageStorage(IWebHostEnvironment environment)
        {
            _environment = environment;
            RootPath = Path.Combine(environment.ContentRootPath, "Storage", "ProductImages");
            Directory.CreateDirectory(RootPath);
        }

        public string RootPath { get; }

        public async Task<string> SaveAsync(
            Stream source,
            string extension,
            CancellationToken cancellationToken = default)
        {
            Directory.CreateDirectory(RootPath);
            var fileName = $"{Guid.NewGuid():N}{extension}";
            var targetPath = Path.Combine(RootPath, fileName);
            await using var output = new FileStream(
                targetPath,
                FileMode.CreateNew,
                FileAccess.Write,
                FileShare.None,
                81920,
                useAsync: true);
            await source.CopyToAsync(output, cancellationToken);
            return $"{RequestPath}/{fileName}";
        }

        public string? ResolveLocalPath(string? imageUrl)
        {
            if (string.IsNullOrWhiteSpace(imageUrl)) return null;
            if (!Uri.TryCreate(imageUrl, UriKind.RelativeOrAbsolute, out var uri)) return null;

            var path = uri.IsAbsoluteUri ? uri.AbsolutePath : imageUrl.Split('?', '#')[0];
            if (!path.StartsWith(RequestPath + "/", StringComparison.OrdinalIgnoreCase))
                return null;

            var fileName = Path.GetFileName(path.Replace('/', Path.DirectorySeparatorChar));
            if (string.IsNullOrWhiteSpace(fileName)) return null;

            var persistentPath = Path.Combine(RootPath, fileName);
            if (File.Exists(persistentPath)) return persistentPath;

            var webRoot = _environment.WebRootPath
                ?? Path.Combine(_environment.ContentRootPath, "wwwroot");
            var legacyPath = Path.Combine(webRoot, "uploads", "products", fileName);
            return File.Exists(legacyPath) ? legacyPath : null;
        }

        public void MigrateLegacyFiles()
        {
            var webRoot = _environment.WebRootPath
                ?? Path.Combine(_environment.ContentRootPath, "wwwroot");
            var legacyDirectory = Path.Combine(webRoot, "uploads", "products");
            if (!Directory.Exists(legacyDirectory)) return;

            Directory.CreateDirectory(RootPath);
            foreach (var sourcePath in Directory.EnumerateFiles(legacyDirectory))
            {
                var destinationPath = Path.Combine(RootPath, Path.GetFileName(sourcePath));
                if (!File.Exists(destinationPath))
                    File.Copy(sourcePath, destinationPath);
            }
        }
    }
}

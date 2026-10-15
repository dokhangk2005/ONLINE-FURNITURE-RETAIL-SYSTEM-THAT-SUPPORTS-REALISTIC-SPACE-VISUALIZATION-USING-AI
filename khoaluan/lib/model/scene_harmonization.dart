class SceneHarmonizationStatus {
  final bool available;
  final String provider;
  final String model;
  final String quality;
  final int maxReferenceImages;
  final String message;

  const SceneHarmonizationStatus({
    required this.available,
    required this.provider,
    required this.model,
    required this.quality,
    required this.maxReferenceImages,
    required this.message,
  });

  factory SceneHarmonizationStatus.fromJson(Map<String, dynamic> json) =>
      SceneHarmonizationStatus(
        available: json['available'] == true,
        provider: (json['provider'] ?? '').toString(),
        model: (json['model'] ?? '').toString(),
        quality: (json['quality'] ?? '').toString(),
        maxReferenceImages: (json['maxReferenceImages'] as num?)?.toInt() ?? 4,
        message: (json['message'] ?? '').toString(),
      );
}

class SceneHarmonizationResult {
  final String imageUrl;
  final bool fromCache;
  final String provider;
  final String model;
  final String quality;

  const SceneHarmonizationResult({
    required this.imageUrl,
    required this.fromCache,
    required this.provider,
    required this.model,
    required this.quality,
  });

  factory SceneHarmonizationResult.fromJson(Map<String, dynamic> json) =>
      SceneHarmonizationResult(
        imageUrl: (json['imageUrl'] ?? '').toString(),
        fromCache: json['fromCache'] == true,
        provider: (json['provider'] ?? '').toString(),
        model: (json['model'] ?? '').toString(),
        quality: (json['quality'] ?? '').toString(),
      );
}

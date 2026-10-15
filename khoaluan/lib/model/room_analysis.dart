import 'dart:math' as math;

class RoomAnalysisResult {
  final String designId;
  final String modelVersion;
  final int width;
  final int height;
  final double floorCoverage;
  final double wallCoverage;
  final String depthMeaning;
  final int depthInferenceMs;
  final int segmentationInferenceMs;
  final int processingMs;
  final DateTime? analyzedAt;
  final bool cached;
  final int cacheAgeSeconds;
  final String depthMapUrl;
  final String floorMaskUrl;
  final String wallMaskUrl;
  final String overlayUrl;
  final RoomPlacementPlane? floorPlane;
  final RoomPlacementPlane? wallPlane;
  final RoomDepthGrid? depthGrid;
  final RoomLightingAnalysis? lighting;
  final double? occlusionCoverage;
  final String occlusionMaskUrl;
  final String foregroundUrl;

  const RoomAnalysisResult({
    required this.designId,
    required this.modelVersion,
    required this.width,
    required this.height,
    required this.floorCoverage,
    required this.wallCoverage,
    required this.depthMeaning,
    required this.depthInferenceMs,
    required this.segmentationInferenceMs,
    required this.processingMs,
    required this.analyzedAt,
    required this.cached,
    required this.cacheAgeSeconds,
    required this.depthMapUrl,
    required this.floorMaskUrl,
    required this.wallMaskUrl,
    required this.overlayUrl,
    required this.floorPlane,
    required this.wallPlane,
    required this.depthGrid,
    required this.lighting,
    required this.occlusionCoverage,
    required this.occlusionMaskUrl,
    required this.foregroundUrl,
  });

  bool get supportsPlacement2B =>
      depthGrid != null && (floorPlane != null || wallPlane != null);
  bool get supportsLighting2C => supportsPlacement2B && lighting != null;
  bool get supportsOcclusion2D =>
      supportsLighting2C &&
      occlusionCoverage != null &&
      occlusionMaskUrl.isNotEmpty &&
      foregroundUrl.isNotEmpty;

  factory RoomAnalysisResult.fromJson(Map<String, dynamic> json) {
    int asInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    double asDouble(String key) => (json[key] as num?)?.toDouble() ?? 0;

    return RoomAnalysisResult(
      designId: (json['designId'] ?? '').toString(),
      modelVersion: (json['modelVersion'] ?? '').toString(),
      width: asInt('width'),
      height: asInt('height'),
      floorCoverage: asDouble('floorCoverage'),
      wallCoverage: asDouble('wallCoverage'),
      depthMeaning: (json['depthMeaning'] ?? '').toString(),
      depthInferenceMs: asInt('depthInferenceMs'),
      segmentationInferenceMs: asInt('segmentationInferenceMs'),
      processingMs: asInt('processingMs'),
      analyzedAt: DateTime.tryParse((json['analyzedAt'] ?? '').toString()),
      cached: json['cached'] == true,
      cacheAgeSeconds: asInt('cacheAgeSeconds'),
      depthMapUrl: (json['depthMapUrl'] ?? '').toString(),
      floorMaskUrl: (json['floorMaskUrl'] ?? '').toString(),
      wallMaskUrl: (json['wallMaskUrl'] ?? '').toString(),
      overlayUrl: (json['overlayUrl'] ?? '').toString(),
      floorPlane: RoomPlacementPlane.tryParse(json['floorPlane']),
      wallPlane: RoomPlacementPlane.tryParse(json['wallPlane']),
      depthGrid: RoomDepthGrid.tryParse(json['depthGrid']),
      lighting: RoomLightingAnalysis.tryParse(json['lighting']),
      occlusionCoverage: (json['occlusionCoverage'] as num?)?.toDouble(),
      occlusionMaskUrl: (json['occlusionMaskUrl'] ?? '').toString(),
      foregroundUrl: (json['foregroundUrl'] ?? '').toString(),
    );
  }
}

class RoomLightingAnalysis {
  final double ambientBrightness;
  final double colorTemperature;
  final double contrast;
  final RoomPlanePoint lightPosition;
  final RoomPlanePoint shadowDirection;
  final double shadowSoftness;
  final double confidence;
  final RoomDepthGrid grid;

  const RoomLightingAnalysis({
    required this.ambientBrightness,
    required this.colorTemperature,
    required this.contrast,
    required this.lightPosition,
    required this.shadowDirection,
    required this.shadowSoftness,
    required this.confidence,
    required this.grid,
  });

  static RoomLightingAnalysis? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final rawLightPosition = json['lightPosition'];
    final rawShadowDirection = json['shadowDirection'];
    final grid = RoomDepthGrid.tryParse(json['grid']);
    if (rawLightPosition is! Map ||
        rawShadowDirection is! Map ||
        grid == null) {
      return null;
    }
    return RoomLightingAnalysis(
      ambientBrightness: (json['ambientBrightness'] as num?)?.toDouble() ?? 0.5,
      colorTemperature: (json['colorTemperature'] as num?)?.toDouble() ?? 0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 0.5,
      lightPosition: RoomPlanePoint.fromJson(
        Map<String, dynamic>.from(rawLightPosition),
      ),
      shadowDirection: RoomPlanePoint.fromJson(
        Map<String, dynamic>.from(rawShadowDirection),
      ),
      shadowSoftness: (json['shadowSoftness'] as num?)?.toDouble() ?? 0.6,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      grid: grid,
    );
  }

  double brightnessAt(double x, double y) => grid.sample(x, y);
}

class RoomPlanePoint {
  final double x;
  final double y;

  const RoomPlanePoint(this.x, this.y);

  factory RoomPlanePoint.fromJson(Map<String, dynamic> json) => RoomPlanePoint(
    (json['x'] as num?)?.toDouble() ?? 0,
    (json['y'] as num?)?.toDouble() ?? 0,
  );
}

class RoomPlacementPlane {
  final String kind;
  final List<RoomPlanePoint> points;
  final double confidence;

  const RoomPlacementPlane({
    required this.kind,
    required this.points,
    required this.confidence,
  });

  static RoomPlacementPlane? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final rawPoints = json['points'];
    if (rawPoints is! List || rawPoints.length != 4) return null;
    final points = rawPoints
        .whereType<Map>()
        .map(
          (point) => RoomPlanePoint.fromJson(Map<String, dynamic>.from(point)),
        )
        .toList();
    if (points.length != 4) return null;
    return RoomPlacementPlane(
      kind: (json['kind'] ?? '').toString(),
      points: points,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RoomDepthGrid {
  final int width;
  final int height;
  final List<int> values;

  const RoomDepthGrid({
    required this.width,
    required this.height,
    required this.values,
  });

  static RoomDepthGrid? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final width = (json['width'] as num?)?.toInt() ?? 0;
    final height = (json['height'] as num?)?.toInt() ?? 0;
    final values =
        (json['values'] as List?)
            ?.whereType<num>()
            .map((value) => value.toInt().clamp(0, 255))
            .toList() ??
        const <int>[];
    if (width <= 0 || height <= 0 || values.length != width * height) {
      return null;
    }
    return RoomDepthGrid(width: width, height: height, values: values);
  }

  double sample(double normalizedX, double normalizedY) {
    final gridX = normalizedX.clamp(0.0, 1.0) * (width - 1);
    final gridY = normalizedY.clamp(0.0, 1.0) * (height - 1);
    final x0 = gridX.floor();
    final y0 = gridY.floor();
    final x1 = math.min(x0 + 1, width - 1);
    final y1 = math.min(y0 + 1, height - 1);
    final tx = gridX - x0;
    final ty = gridY - y0;
    double at(int x, int y) => values[y * width + x] / 255.0;
    final top = at(x0, y0) * (1 - tx) + at(x1, y0) * tx;
    final bottom = at(x0, y1) * (1 - tx) + at(x1, y1) * tx;
    return top * (1 - ty) + bottom * ty;
  }
}

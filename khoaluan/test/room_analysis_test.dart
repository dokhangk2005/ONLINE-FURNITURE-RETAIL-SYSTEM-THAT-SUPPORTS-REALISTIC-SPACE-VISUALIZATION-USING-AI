import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/room_analysis.dart';

void main() {
  test('đọc kết quả phân tích không gian 2A từ API', () {
    final result = RoomAnalysisResult.fromJson({
      'designId': 'room-1',
      'modelVersion': 'depth+segmentation',
      'width': 1920,
      'height': 1080,
      'floorCoverage': 0.28,
      'wallCoverage': 0.44,
      'depthMeaning': '0=far,1=near',
      'depthInferenceMs': 800,
      'segmentationInferenceMs': 250,
      'processingMs': 2100,
      'analyzedAt': '2026-08-08T00:00:00Z',
      'cached': true,
      'cacheAgeSeconds': 12,
      'depthMapUrl': '/depth',
      'floorMaskUrl': '/floor',
      'wallMaskUrl': '/wall',
      'overlayUrl': '/overlay',
      'floorPlane': {
        'kind': 'floor',
        'confidence': 0.82,
        'points': [
          {'x': 0.2, 'y': 0.55},
          {'x': 0.8, 'y': 0.55},
          {'x': 1.0, 'y': 1.0},
          {'x': 0.0, 'y': 1.0},
        ],
      },
      'depthGrid': {
        'width': 2,
        'height': 2,
        'values': [0, 255, 0, 255],
      },
      'lighting': {
        'ambientBrightness': 0.4,
        'colorTemperature': 0.3,
        'contrast': 0.5,
        'lightPosition': {'x': 0.2, 'y': 0.1},
        'shadowDirection': {'x': 0.4, 'y': 0.9},
        'shadowSoftness': 0.7,
        'confidence': 0.8,
        'grid': {
          'width': 2,
          'height': 2,
          'values': [64, 128, 192, 255],
        },
      },
      'occlusionCoverage': 0.22,
      'occlusionMaskUrl': '/occlusion-mask',
      'foregroundUrl': '/foreground',
    });

    expect(result.designId, 'room-1');
    expect(result.width, 1920);
    expect(result.floorCoverage, closeTo(0.28, 0.0001));
    expect(result.cached, isTrue);
    expect(result.cacheAgeSeconds, 12);
    expect(result.analyzedAt?.isUtc, isTrue);
    expect(result.overlayUrl, '/overlay');
    expect(result.supportsPlacement2B, isTrue);
    expect(result.floorPlane?.points, hasLength(4));
    expect(result.depthGrid?.sample(0, 0.5), closeTo(0, 0.001));
    expect(result.depthGrid?.sample(1, 0.5), closeTo(1, 0.001));
    expect(result.supportsLighting2C, isTrue);
    expect(result.lighting?.colorTemperature, closeTo(0.3, 0.001));
    expect(result.lighting?.brightnessAt(1, 1), closeTo(1, 0.001));
    expect(result.supportsOcclusion2D, isTrue);
    expect(result.occlusionCoverage, closeTo(0.22, 0.001));
    expect(result.foregroundUrl, '/foreground');
  });
}

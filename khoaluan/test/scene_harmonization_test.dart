import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/scene_harmonization.dart';

void main() {
  test('đọc đúng trạng thái cấu hình AI tạo ảnh', () {
    final status = SceneHarmonizationStatus.fromJson({
      'available': true,
      'provider': 'OpenAI',
      'model': 'gpt-image-2',
      'quality': 'medium',
      'maxReferenceImages': 1,
      'message': 'ready',
    });

    expect(status.available, isTrue);
    expect(status.model, 'gpt-image-2');
    expect(status.maxReferenceImages, 1);
  });

  test('đọc đúng kết quả và trạng thái cache AI tạo ảnh', () {
    final result = SceneHarmonizationResult.fromJson({
      'imageUrl': '/api/room-designs/id/harmonized/key',
      'fromCache': true,
      'provider': 'OpenAI',
      'model': 'gpt-image-2',
      'quality': 'medium',
    });

    expect(result.fromCache, isTrue);
    expect(result.imageUrl, contains('/harmonized/'));
  });
}

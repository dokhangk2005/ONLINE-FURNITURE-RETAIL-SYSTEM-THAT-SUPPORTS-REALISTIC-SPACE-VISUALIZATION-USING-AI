import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/product.dart';

void main() {
  test('dùng URL hiển thị ổn định nhưng vẫn giữ URL nguồn khi cập nhật', () {
    final image = ProductImage.fromJson({
      'imageId': 6,
      'variantId': 3,
      'imageUrl': '/uploads/products/original.jpg',
      'displayImageUrl': '/uploads/products/by-id/6',
      'isThumbnail': true,
      'createdAt': '2026-08-10T00:00:00Z',
    });

    expect(image.imageUrl, '/uploads/products/by-id/6');
    expect(image.toJson()['imageUrl'], '/uploads/products/original.jpg');
  });
}

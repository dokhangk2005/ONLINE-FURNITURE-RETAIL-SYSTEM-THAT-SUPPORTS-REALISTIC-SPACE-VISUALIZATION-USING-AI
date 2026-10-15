import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/utils/perspective_yaw.dart';

void main() {
  const square = [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)];

  test('quay phải làm cạnh trái lùi và ngắn hơn', () {
    final turned = applyPerspectiveYaw(square, 0.7);

    expect(turned[0].dx, greaterThan(0));
    expect(turned[0].dy, greaterThan(0));
    expect(turned[3].dy, lessThan(1));
    expect(turned[1].dx, closeTo(1, 0.0001));
  });

  test('quay trái làm cạnh phải lùi và ngắn hơn', () {
    final turned = applyPerspectiveYaw(square, -0.7);

    expect(turned[1].dx, lessThan(1));
    expect(turned[1].dy, greaterThan(0));
    expect(turned[2].dy, lessThan(1));
    expect(turned[0].dx, closeTo(0, 0.0001));
  });
}

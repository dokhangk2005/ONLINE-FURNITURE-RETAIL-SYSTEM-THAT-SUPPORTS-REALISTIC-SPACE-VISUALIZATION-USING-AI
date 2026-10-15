import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/utils/projective_transform.dart';

void main() {
  test('ma trận phối cảnh ánh xạ đúng bốn góc', () {
    final source = [
      const Offset(0, 0),
      const Offset(200, 0),
      const Offset(200, 200),
      const Offset(0, 200),
    ];
    final target = [
      const Offset(30, 10),
      const Offset(170, 20),
      const Offset(200, 190),
      const Offset(0, 180),
    ];
    final matrix = buildProjectiveTransform(source, target);

    for (var index = 0; index < 4; index++) {
      final transformed = MatrixUtils.transformPoint(matrix, source[index]);
      expect(transformed.dx, closeTo(target[index].dx, 0.001));
      expect(transformed.dy, closeTo(target[index].dy, 0.001));
    }
  });
}

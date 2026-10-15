import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/room_analysis.dart';
import 'package:khoaluan/utils/placement_snap.dart';

void main() {
  const plane = RoomPlacementPlane(
    kind: 'floor',
    confidence: 0.8,
    points: [
      RoomPlanePoint(0.25, 0.4),
      RoomPlanePoint(0.75, 0.4),
      RoomPlanePoint(0.9, 1),
      RoomPlanePoint(0.1, 1),
    ],
  );

  test('sàn cho phép đặt đồ ngoài cạnh ngang AI nhận diện thiếu', () {
    final snapped = snapToPlacementPlane(plane, 'floor', 0.05, 0.7);

    expect(snapped.dx, closeTo(0.05, 0.0001));
    expect(snapped.dy, closeTo(0.7, 0.0001));
  });

  test('sàn vẫn ngăn kéo đồ lên phần tường phía trên đường chân sàn', () {
    final snapped = snapToPlacementPlane(plane, 'floor', 0.5, 0.2);

    expect(snapped.dx, closeTo(0.5, 0.0001));
    expect(snapped.dy, closeTo(0.415, 0.0001));
  });

  test('tường vẫn bám đầy đủ theo hai cạnh của mặt phẳng', () {
    final snapped = snapToPlacementPlane(plane, 'wall', 0.02, 0.7);

    expect(snapped.dx, greaterThan(0.1));
  });

  test('tường trái và phải giữ vật thể ở đúng phía', () {
    final left = snapToPlacementPlane(plane, 'wall-left', 0.8, 0.7);
    final right = snapToPlacementPlane(plane, 'wall-right', 0.2, 0.7);

    expect(left.dx, lessThan(0.5));
    expect(right.dx, greaterThan(0.5));
  });
}

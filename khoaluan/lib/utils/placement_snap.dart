import 'dart:ui';

import '../model/room_analysis.dart';

/// Keeps an item on the detected surface without turning an imperfect floor
/// segmentation into an artificial horizontal barrier.
Offset snapToPlacementPlane(
  RoomPlacementPlane? plane,
  String surface,
  double x,
  double y,
) {
  if (plane == null || plane.points.length != 4) {
    return Offset(x.clamp(0.02, 0.98), y.clamp(0.02, 0.98));
  }

  final topLeft = plane.points[0];
  final topRight = plane.points[1];
  final bottomRight = plane.points[2];
  final bottomLeft = plane.points[3];
  final topY = (topLeft.y + topRight.y) / 2;
  final bottomY = (bottomLeft.y + bottomRight.y) / 2;
  final minY = (topY + 0.015).clamp(0.01, 0.98);
  final maxY = (bottomY - 0.015).clamp(minY, 0.99);
  final snappedY = y.clamp(minY, maxY);

  // The floor mask is an AI suggestion. Keeping only its vertical horizon is
  // safer: missed strips near either side remain usable floor, while dragging
  // an item onto the wall above the horizon is still prevented.
  if (surface == 'floor') {
    return Offset(x.clamp(0.02, 0.98), snappedY);
  }

  final progress = bottomY - topY < 0.001
      ? 0.5
      : ((snappedY - topY) / (bottomY - topY)).clamp(0.0, 1.0);
  final left = topLeft.x + (bottomLeft.x - topLeft.x) * progress;
  final right = topRight.x + (bottomRight.x - topRight.x) * progress;

  if (surface == 'wall-left') {
    final maxX = (left - 0.02).clamp(0.08, 0.48);
    return Offset(x.clamp(0.02, maxX), snappedY);
  }
  if (surface == 'wall-right') {
    final minX = (right + 0.02).clamp(0.52, 0.92);
    return Offset(x.clamp(minX, 0.98), snappedY);
  }

  final minX = (left + 0.015).clamp(0.01, 0.98);
  final maxX = (right - 0.015).clamp(minX, 0.99);
  return Offset(x.clamp(minX, maxX), snappedY);
}

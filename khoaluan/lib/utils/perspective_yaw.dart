import 'dart:ui';

/// Applies a 3D-like horizontal turn to a four-corner 2D cutout.
///
/// Positive values move the left edge farther away; negative values move the
/// right edge farther away. This cannot reveal an unseen side of a product,
/// but it provides convincing foreshortening for moderate angles.
List<Offset> applyPerspectiveYaw(List<Offset> corners, double yaw) {
  if (corners.length != 4) return List<Offset>.from(corners);
  final amount = yaw.clamp(-1.0, 1.0);
  if (amount.abs() < 0.0001) return List<Offset>.from(corners);

  final strength = amount.abs();
  final horizontalInset = 0.43 * strength;
  final verticalTaper = 0.18 * strength;

  return corners.map((corner) {
    final normalizedX = corner.dx.clamp(0.0, 1.0);
    final farWeight = amount > 0 ? 1 - normalizedX : normalizedX;
    final x = amount > 0
        ? horizontalInset + corner.dx * (1 - horizontalInset)
        : corner.dx * (1 - horizontalInset);
    final verticalScale = 1 - verticalTaper * farWeight;
    final y = 0.5 + (corner.dy - 0.5) * verticalScale;
    return Offset(x, y);
  }).toList();
}

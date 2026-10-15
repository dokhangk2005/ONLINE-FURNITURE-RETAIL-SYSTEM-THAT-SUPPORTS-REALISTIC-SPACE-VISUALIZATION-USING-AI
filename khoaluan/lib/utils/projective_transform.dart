import 'package:flutter/widgets.dart';

Matrix4 buildProjectiveTransform(List<Offset> source, List<Offset> target) {
  if (source.length != 4 || target.length != 4) return Matrix4.identity();
  final equations = List.generate(8, (_) => List.filled(9, 0.0));
  for (var index = 0; index < 4; index++) {
    final x = source[index].dx;
    final y = source[index].dy;
    final u = target[index].dx;
    final v = target[index].dy;
    equations[index * 2]
      ..[0] = x
      ..[1] = y
      ..[2] = 1
      ..[6] = -u * x
      ..[7] = -u * y
      ..[8] = u;
    equations[index * 2 + 1]
      ..[3] = x
      ..[4] = y
      ..[5] = 1
      ..[6] = -v * x
      ..[7] = -v * y
      ..[8] = v;
  }
  final solution = _solveLinearSystem(equations);
  if (solution == null) return Matrix4.identity();
  return Matrix4.identity()
    ..setEntry(0, 0, solution[0])
    ..setEntry(0, 1, solution[1])
    ..setEntry(0, 3, solution[2])
    ..setEntry(1, 0, solution[3])
    ..setEntry(1, 1, solution[4])
    ..setEntry(1, 3, solution[5])
    ..setEntry(3, 0, solution[6])
    ..setEntry(3, 1, solution[7]);
}

List<double>? _solveLinearSystem(List<List<double>> matrix) {
  const count = 8;
  for (var column = 0; column < count; column++) {
    var pivot = column;
    for (var row = column + 1; row < count; row++) {
      if (matrix[row][column].abs() > matrix[pivot][column].abs()) {
        pivot = row;
      }
    }
    if (matrix[pivot][column].abs() < 1e-9) return null;
    final temporary = matrix[column];
    matrix[column] = matrix[pivot];
    matrix[pivot] = temporary;

    final divisor = matrix[column][column];
    for (var value = column; value <= count; value++) {
      matrix[column][value] /= divisor;
    }
    for (var row = 0; row < count; row++) {
      if (row == column) continue;
      final factor = matrix[row][column];
      for (var value = column; value <= count; value++) {
        matrix[row][value] -= factor * matrix[column][value];
      }
    }
  }
  return List.generate(count, (index) => matrix[index][count]);
}

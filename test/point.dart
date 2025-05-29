import 'dart:math' show sqrt;

/// A Point class for testing custom objects in DisjointSet
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  /// Calculates the Euclidean distance to another point
  double distanceTo(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
  
  /// Helper method to check if two points are within a certain distance threshold
  bool isCloseTo(Point other, double threshold) {
    return distanceTo(other) <= threshold;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x,$y)';

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  
  static Point fromJson(dynamic json) =>
      Point(json['x'] as int, json['y'] as int);
}

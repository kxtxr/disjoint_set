# Disjoint Set (Union-Find)

A highly efficient implementation of the Disjoint Set (Union-Find) data structure for Dart and Flutter applications.

[![pub package](https://img.shields.io/pub/v/disjoint_set.svg)](https://pub.dev/packages/disjoint_set)
[![Build Status](https://github.com/kxtxr/disjoint_set/workflows/Dart%20Package%20CI/badge.svg)](https://github.com/kxtxr/disjoint_set/actions)

## Features

* Generic type support for any Dart type
* O(α(n)) time complexity for operations through:
  * Union by rank optimization
  * Path compression optimization
* Comprehensive set management operations
* Advanced features like custom merging and serialization
* Support for removal of elements while maintaining set integrity
* Full documentation and examples
* 100% test coverage

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  disjoint_set: ^1.0.0
```

## Usage

### Basic Operations

```dart
import 'package:disjoint_set/disjoint_set.dart';

void main() {
  // Create a new DisjointSet for strings
  final ds = DisjointSet<String>();

  // Add elements to the structure
  ds.makeSet('A');
  ds.makeSet('B');
  ds.makeSet('C');

  // Join some elements
  ds.union('A', 'B');

  // Check if elements are connected
  print(ds.connected('A', 'B')); // true
  print(ds.connected('A', 'C')); // false

  // Get all sets
  print(ds.getAllSets()); // [{'A', 'B'}, {'C'}]
}
```

### Advanced Features

#### Custom Objects

```dart
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  double distanceTo(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy).toDouble();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

void main() {
  final ds = DisjointSet<Point>();
  
  final p1 = Point(0, 0);
  final p2 = Point(1, 1);
  
  ds.makeSet(p1);
  ds.makeSet(p2);
  
  // Merge points that are close to each other
  ds.mergeIf((a, b) => a.distanceTo(b) < 2.0);
}
```

#### Serialization

```dart
void main() {
  final ds = DisjointSet<String>();
  ds.makeSet('A');
  ds.makeSet('B');
  ds.union('A', 'B');

  // Convert to JSON
  final jsonMap = ds.toJson();
  
  // Create from JSON
  final newDs = DisjointSet<String>.fromJson(
    jsonMap,
    fromJsonT: (dynamic json) => json as String,
  );
}
```

## API Reference

### Core Operations

* `makeSet(T value)` - Creates a new singleton set
* `find(T value)` - Returns the representative element
* `union(T a, T b)` - Merges sets containing a and b
* `connected(T a, T b)` - Checks if a and b are in the same set
* `getSet(T value)` - Returns all elements in value's set
* `getAllSets()` - Returns all disjoint sets

### Advanced Operations

* `remove(T value)` - Removes an element while maintaining set integrity
* `mergeIf(bool Function(T, T) predicate)` - Merges elements satisfying a predicate
* `toJson()` / `fromJson()` - Serialization support

## Performance

Operations have near-constant time complexity O(α(n)), where α is the inverse Ackermann function. In practice, α(n) ≤ 4 for all practical values of n, making operations effectively constant time.

| Operation | Time Complexity |
|-----------|----------------|
| makeSet   | O(1)          |
| find      | O(α(n))       |
| union     | O(α(n))       |
| connected | O(α(n))       |
| getSet    | O(n * α(n))   |
| getAllSets| O(n * α(n))   |

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

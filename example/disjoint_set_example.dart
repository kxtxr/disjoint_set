// Copyright (c) 2025, the disjoint_set project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:disjoint_set/disjoint_set.dart';

/// A Point class to represent 2D coordinates.
/// Used to demonstrate DisjointSet with custom objects.
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  // Distance calculation
  double distanceTo(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy)
        .toDouble(); // Using squared distance for efficiency
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x,$y)';

  // Conversion to/from JSON
  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  static Point fromJson(dynamic json) =>
      Point(json['x'] as int, json['y'] as int);
}

/// Main entry point showing different aspects of the DisjointSet data structure
void main() {
  print('Disjoint Set (Union-Find) Examples\n');
  print(
      'This example demonstrates the key features of the DisjointSet package:');
  print('  * Basic operations (makeSet, find, union)');
  print('  * Set queries (connected, getSet, getAllSets)');
  print('  * Advanced features (mergeIf, remove)');
  print('  * Serialization with toJson and fromJson');
  print('  * Performance characteristics with different dataset sizes');
  print('  * Working with custom objects\n');

  // Basic operations
  basicOperations();

  // Set queries
  setQueries();

  // Advanced features
  advancedFeatures();

  // Serialization
  serializationExample();

  // Performance characteristics
  performanceExample();

  // Custom object example
  customObjectExample();
}

/// Demonstrates basic DisjointSet operations: makeSet, find, union
///
/// These are the core operations that form the foundation of the data structure:
/// - makeSet: Creates a new singleton set containing one element
/// - find: Returns the representative element of a set
/// - union: Merges two sets together
void basicOperations() {
  print('\n=== Basic Operations ===\n');

  // Create a new DisjointSet for strings
  // DisjointSet is a generic class that can work with any type
  final ds = DisjointSet<String>();

  // Add elements to the structure
  print('Creating singleton sets for A, B, C, D, E');
  ds.makeSet('A');
  ds.makeSet('B');
  ds.makeSet('C');
  ds.makeSet('D');
  ds.makeSet('E');

  // Initial state
  print('\nInitial state:');
  print('Number of elements: ${ds.size}');
  print('Number of sets: ${ds.setCount}');

  // Find representatives
  print('\nRepresentatives:');
  print('Representative of A: ${ds.find('A')}');
  print('Representative of B: ${ds.find('B')}');

  // Union operations
  print('\nPerforming unions:');
  print('Union A and B');
  ds.union('A', 'B');

  print('Union C and D');
  ds.union('C', 'D');

  print('Union A and C');
  ds.union('A', 'C');

  // After unions
  print('\nAfter unions:');
  print('Number of sets: ${ds.setCount}');

  // Find representatives after unions
  print('\nRepresentatives after unions:');
  print('Representative of A: ${ds.find('A')}');
  print('Representative of B: ${ds.find('B')}');
  print('Representative of C: ${ds.find('C')}');
  print('Representative of D: ${ds.find('D')}');
  print('Representative of E: ${ds.find('E')}');
}

/// Demonstrates set query operations: connected, getSet, getAllSets
void setQueries() {
  print('\n=== Set Queries ===\n');

  final ds = DisjointSet<int>();

  // Create sets for numbers 0-9
  for (int i = 0; i < 10; i++) {
    ds.makeSet(i);
  }

  // Create some connections
  ds.union(0, 1);
  ds.union(1, 2);
  ds.union(3, 4);
  ds.union(4, 5);
  ds.union(6, 7);
  ds.union(7, 8);

  // Test connectivity
  print('Connectivity tests:');
  print('0 and 2 connected: ${ds.connected(0, 2)}'); // true
  print('0 and 3 connected: ${ds.connected(0, 3)}'); // false
  print('3 and 5 connected: ${ds.connected(3, 5)}'); // true
  print('6 and 8 connected: ${ds.connected(6, 8)}'); // true
  print('0 and 9 connected: ${ds.connected(0, 9)}'); // false

  // Get all elements in a specific set
  print('\nElements in set containing 0:');
  print(ds.getSet(0)); // {0, 1, 2}

  print('\nElements in set containing 4:');
  print(ds.getSet(4)); // {3, 4, 5}

  // Get all sets
  print('\nAll disjoint sets:');
  final allSets = ds.getAllSets();
  for (int i = 0; i < allSets.length; i++) {
    print('Set ${i + 1}: ${allSets[i]}');
  }
}

/// Demonstrates advanced features: mergeIf, remove
///
/// - mergeIf: Combines elements that satisfy a custom equivalence predicate
/// - remove: Removes an element from its set while maintaining structure
void advancedFeatures() {
  print('\n=== Advanced Features ===\n');

  // mergeIf example - grouping numbers by their parity (odd/even)
  // This is a perfect use case for mergeIf - a simple equivalence relation
  final ds1 = DisjointSet<int>();

  // Add numbers 1-10
  for (int i = 1; i <= 10; i++) {
    ds1.makeSet(i);
  }

  print('Initial sets (10 singleton sets):');
  print('Number of sets: ${ds1.setCount}');

  // Merge numbers with the same parity (odd/even)
  print('\nMerging numbers with the same parity (odd/even):');
  // The predicate function returns true for numbers that should be in the same set
  ds1.mergeIf((a, b) => a % 2 == b % 2);

  print('After mergeIf:');
  print('Number of sets: ${ds1.setCount}'); // Should be 2 (odd and even)

  final oddSet = ds1.getSet(1);
  final evenSet = ds1.getSet(2);

  print('Odd numbers set: $oddSet');
  print('Even numbers set: $evenSet');

  // Remove example
  print('\nRemove example:');
  final ds2 = DisjointSet<String>();

  // Create sets
  for (final c in ['A', 'B', 'C', 'D', 'E']) {
    ds2.makeSet(c);
  }

  // Join some elements
  ds2.union('A', 'B');
  ds2.union('B', 'C');

  print('Before removal:');
  print('Set A: ${ds2.getSet('A')}'); // {A, B, C}
  print('Connected A-B: ${ds2.connected('A', 'B')}'); // true

  // Remove B - this demonstrates how the structure maintains integrity
  // even when removing elements that might be representatives
  print('\nRemoving B:');
  ds2.remove('B');

  print('After removal:');
  print('Set A: ${ds2.getSet('A')}'); // {A, C}
  print('Connected A-C: ${ds2.connected('A', 'C')}'); // true
  print('B exists: ${ds2.find('B') != null}'); // false
}

/// Demonstrates serialization with toJson and fromJson
///
/// This feature allows saving the disjoint set structure to JSON format
/// and restoring it later, preserving all set relationships.
void serializationExample() {
  print('\n=== Serialization ===\n');

  final ds = DisjointSet<String>();

  // Create some sets
  ds.makeSet('A');
  ds.makeSet('B');
  ds.makeSet('C');
  ds.makeSet('D');
  ds.makeSet('E');

  // Join some elements
  ds.union('A', 'B');
  ds.union('C', 'D');

  print('Original disjoint set:');
  print('Sets: ${ds.getAllSets()}');

  // Convert to JSON
  final jsonMap = ds.toJson();
  final jsonString = jsonEncode(jsonMap);

  print('\nJSON representation:');
  print(jsonString);

  // Create a new DisjointSet from the JSON
  final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
  final newDs = DisjointSet<String>.fromJson(
    decodedMap,
    fromJsonT: (dynamic json) => json as String,
  );

  print('\nDeserialized disjoint set:');
  print('Sets: ${newDs.getAllSets()}');

  // Verify connections are preserved
  print('\nVerifying connections:');
  print('A-B connected: ${newDs.connected('A', 'B')}'); // true
  print('C-D connected: ${newDs.connected('C', 'D')}'); // true
  print('A-C connected: ${newDs.connected('A', 'C')}'); // false
}

/// Demonstrates performance characteristics with different sizes
///
/// The DisjointSet implementation uses two key optimizations:
/// - Union by rank: Keeps trees balanced by attaching smaller trees under larger ones
/// - Path compression: Flattens the structure during find operations
///
/// These optimizations together provide a near-constant time complexity for operations.
void performanceExample() {
  print('\n=== Performance Characteristics ===\n');
  print('The DisjointSet implementation uses two optimizations:');
  print('  * Union by rank: Keeps trees balanced');
  print(
      '  * Path compression: Flattens the structure during find operations\n');

  // Performance with different sizes
  for (final size in [100, 1000, 10000]) {
    print('Testing with $size elements:');
    final ds = DisjointSet<int>();

    // Measure makeSet
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < size; i++) {
      ds.makeSet(i);
    }
    final makeSetTime = stopwatch.elapsedMilliseconds;

    // Measure union (create a long chain)
    stopwatch.reset();
    for (int i = 0; i < size - 1; i++) {
      ds.union(i, i + 1);
    }
    final unionTime = stopwatch.elapsedMilliseconds;

    // Measure find (first and last element)
    stopwatch.reset();
    ds.find(0);
    ds.find(size - 1);
    final findTime = stopwatch.elapsedMicroseconds;

    // Report times
    print('  makeSet for $size elements: $makeSetTime ms');
    print('  union for ${size - 1} pairs: $unionTime ms');
    print('  find after compression: $findTime µs');
    print('  final set count: ${ds.setCount}');
    print('');
  }
}

/// Demonstrates using DisjointSet with custom objects
///
/// This example shows how to use DisjointSet with custom classes,
/// including handling serialization for custom objects.
void customObjectExample() {
  print('\n=== Custom Object Example ===\n');

  // Create some points
  final points = [
    Point(1, 2),
    Point(2, 3),
    Point(10, 10),
    Point(11, 12),
    Point(20, 20),
    Point(100, 100),
  ];

  // Create a DisjointSet for Points
  final ds = DisjointSet<Point>();

  // Add all points
  for (final point in points) {
    ds.makeSet(point);
  }

  print('Initial points:');
  for (final point in points) {
    print('  $point');
  }

  // Group points that are close to each other (squared distance < 25)
  print('\nGrouping points with squared distance < 25:');
  print('Note: mergeIf creates transitive relationships, which may not be');
  print('ideal for distance-based clustering. For real applications, consider');
  print('using a graph-based approach for non-transitive relationships.');
  ds.mergeIf((a, b) => a.distanceTo(b) < 25);

  // Print the resulting clusters
  print('\nResulting clusters:');
  final clusters = ds.getAllSets();
  for (int i = 0; i < clusters.length; i++) {
    print('Cluster ${i + 1}: ${clusters[i]}');
  }

  // Serialization with custom objects
  print('\nSerializing custom objects:');
  final jsonMap = ds.toJson();

  // For custom objects, we need to handle the serialization manually
  final Map<String, dynamic> customJson = {
    'elements': (jsonMap['elements'] as List<dynamic>)
        .map((p) => (p as Point).toJson())
        .toList(),
    'sets': jsonMap['sets'],
  };

  final jsonString = jsonEncode(customJson);
  print('JSON: $jsonString');

  // Deserializing
  print('\nDeserializing custom objects:');
  final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;

  final customDecodedJson = {
    'elements':
        (decodedMap['elements'] as List<dynamic>).map(Point.fromJson).toList(),
    'sets': decodedMap['sets'],
  };

  final newDs = DisjointSet<Point>.fromJson(
    customDecodedJson,
    fromJsonT: (dynamic json) => json as Point,
  );

  print('Deserialized clusters:');
  final newClusters = newDs.getAllSets();
  for (int i = 0; i < newClusters.length; i++) {
    print('Cluster ${i + 1}: ${newClusters[i]}');
  }
}

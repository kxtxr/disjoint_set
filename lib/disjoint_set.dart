// Copyright (c) 2025, the disjoint_set project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

/// A highly efficient implementation of the Disjoint Set (Union-Find) data structure.
///
/// This library provides a generic [DisjointSet] class that implements a disjoint-set
/// data structure with both union-by-rank and path compression optimizations for near-constant
/// time complexity operations.
///
/// ## Features
///
/// * Generic type support for any Dart type
/// * Union-by-rank and path compression optimizations for O(α(n)) complexity
/// * Complete set management operations
/// * Advanced features like custom merging and serialization
/// * Support for removal of elements while maintaining set integrity
/// * Full documentation and examples
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:disjoint_set/disjoint_set.dart';
///
/// void main() {
///   // Create a new DisjointSet for strings
///   final ds = DisjointSet<String>();
///
///   // Add elements to the structure
///   ds.makeSet('A');
///   ds.makeSet('B');
///   ds.makeSet('C');
///
///   // Join some elements
///   ds.union('A', 'B');
///
///   // Check if elements are in the same set
///   print(ds.connected('A', 'B')); // true
///   print(ds.connected('A', 'C')); // false
///
///   // Get all sets
///   print(ds.getAllSets()); // [{'A', 'B'}, {'C'}]
/// }
/// ```
///
/// See the `example` folder for more comprehensive examples.
library disjoint_set;

export 'src/disjoint_set_base.dart';

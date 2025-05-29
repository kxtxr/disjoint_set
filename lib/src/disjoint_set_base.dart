// Copyright (c) 2025, the disjoint_set project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:collection';

/// Internal node class to represent elements in the disjoint set.
///
/// Each node contains:
/// - A reference to its parent node (or itself if it's a root)
/// - A rank value used for union-by-rank optimization
/// - The value of type T that this node represents
class _Node<T> {
  /// The parent node (points to self if this is a root node)
  _Node<T>? _parent;

  /// The rank of this node (used for union by rank optimization)
  int rank = 0;

  /// The value stored in this node
  final T value;

  /// Creates a new node with the given value.
  ///
  /// Initially, the node is its own parent (a singleton set)
  /// and has a rank of 0.
  _Node(this.value) {
    // Initialize parent to self
    _parent = this;
  }

  /// Gets the parent node (with null safety)
  _Node<T> get parent => _parent!;

  /// Sets the parent node
  set parent(_Node<T> node) {
    _parent = node;
  }

  @override
  String toString() => value.toString();
}

/// A highly efficient implementation of the Disjoint Set (Union-Find) data structure.
///
/// This implementation uses both *union by rank* and *path compression* optimizations
/// to achieve near-constant time complexity for operations (O(α(n)), where α is the
/// inverse Ackermann function).
///
/// A disjoint-set data structure maintains a collection of disjoint dynamic sets.
/// Each set is identified by a representative member (also called the parent or root).
///
/// Typical applications include:
/// - Kruskal's algorithm for finding minimum spanning trees
/// - Connected components in undirected graphs
/// - Network connectivity and circuit design
/// - Image processing for connected component labeling
///
/// Example usage:
/// ```dart
/// final ds = DisjointSet<String>();
/// ds.makeSet('A');
/// ds.makeSet('B');
/// ds.makeSet('C');
///
/// ds.union('A', 'B');
/// print(ds.connected('A', 'B')); // true
/// print(ds.connected('A', 'C')); // false
///
/// print(ds.find('A') == ds.find('B')); // true
/// print(ds.getAllSets()); // [{'A', 'B'}, {'C'}]
/// ```
class DisjointSet<T> {
  /// Maps values to their corresponding nodes in the disjoint set.
  final Map<T, _Node<T>> _nodes = <T, _Node<T>>{};

  /// Creates a new DisjointSet.
  DisjointSet();

  /// Creates a singleton set containing [value] if it doesn't already exist.
  ///
  /// If [value] is already in the structure, this method has no effect.
  ///
  /// Time complexity: O(1)
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ```
  void makeSet(T value) {
    if (!_nodes.containsKey(value)) {
      _nodes[value] = _Node<T>(value);
    }
  }

  /// Finds the representative (root) element of the set containing [value].
  ///
  /// This method implements path compression: all nodes along the path to the
  /// root are made direct children of the root, which significantly speeds up
  /// future operations. This is one of the key optimizations that gives the
  /// DisjointSet its efficiency.
  ///
  /// Returns the value of the representative element. If [value] is not in
  /// any set (i.e., makeSet was never called for it), returns null.
  ///
  /// Time complexity: O(α(n)) amortized, where α is the inverse Ackermann function
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.union('A', 'B');
  /// print(ds.find('A') == ds.find('B')); // true
  /// ```
  T? find(T value) {
    if (!_nodes.containsKey(value)) {
      return null;
    }

    // Find the root and apply path compression
    final _Node<T> root = _findNode(_nodes[value]!);
    return root.value;
  }

  /// Internal method to find the root node of the given node and apply path compression.
  ///
  /// This is a helper method for [find] that works with _Node objects directly.
  _Node<T> _findNode(_Node<T> node) {
    // If node is not the root, recursively find the root
    if (node.parent != node) {
      // Path compression: Make the node point directly to the root
      node.parent = _findNode(node.parent);
    }
    return node.parent;
  }

  /// Merges the sets containing [a] and [b].
  ///
  /// This method uses union by rank: the root with the smaller rank is made
  /// a child of the root with the larger rank. If ranks are equal, one is
  /// arbitrarily chosen as the new root and its rank is incremented.
  ///
  /// If either [a] or [b] is not in any set (i.e., makeSet was never called for it),
  /// it will be automatically added.
  ///
  /// Time complexity: O(α(n)) amortized, where α is the inverse Ackermann function
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.union('A', 'B');
  /// print(ds.connected('A', 'B')); // true
  /// ```
  void union(T a, T b) {
    // Ensure both elements exist in the structure
    makeSet(a);
    makeSet(b);

    // Find roots of each value
    final _Node<T> rootA = _findNode(_nodes[a]!);
    final _Node<T> rootB = _findNode(_nodes[b]!);

    // If they're already in the same set, nothing to do
    if (rootA == rootB) {
      return;
    }

    // Union by rank: attach smaller rank tree under root of higher rank tree
    if (rootA.rank < rootB.rank) {
      rootA.parent = rootB;
    } else if (rootA.rank > rootB.rank) {
      rootB.parent = rootA;
    } else {
      // If ranks are the same, make one the root and increment its rank
      rootB.parent = rootA;
      rootA.rank += 1;
    }
  }

  /// Checks if [a] and [b] belong to the same set.
  ///
  /// Returns `true` if both elements are in the same set, `false` otherwise.
  /// If either element is not in any set, returns `false`.
  ///
  /// Time complexity: O(α(n)) amortized, where α is the inverse Ackermann function
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.makeSet('C');
  /// ds.union('A', 'B');
  /// print(ds.connected('A', 'B')); // true
  /// print(ds.connected('A', 'C')); // false
  /// ```
  bool connected(T a, T b) {
    // If either element doesn't exist, they're not connected
    if (!_nodes.containsKey(a) || !_nodes.containsKey(b)) {
      return false;
    }

    // Two elements are connected if they have the same root
    return _findNode(_nodes[a]!) == _findNode(_nodes[b]!);
  }

  /// Returns all elements in the same set as [value].
  ///
  /// If [value] is not in any set, returns an empty set.
  ///
  /// Time complexity: O(n * α(n)), where n is the total number of elements
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.makeSet('C');
  /// ds.union('A', 'B');
  /// print(ds.getSet('A')); // {'A', 'B'}
  /// ```
  Set<T> getSet(T value) {
    if (!_nodes.containsKey(value)) {
      return <T>{};
    }

    final _Node<T> root = _findNode(_nodes[value]!);
    final result = <T>{};

    // Find all elements with the same root
    for (final entry in _nodes.entries) {
      if (_findNode(entry.value) == root) {
        result.add(entry.key);
      }
    }

    return result;
  }

  /// Returns all disjoint sets as a list of sets.
  ///
  /// Time complexity: O(n * α(n)), where n is the total number of elements
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.makeSet('C');
  /// ds.union('A', 'B');
  /// print(ds.getAllSets()); // [{'A', 'B'}, {'C'}]
  /// ```
  List<Set<T>> getAllSets() {
    final Map<_Node<T>, Set<T>> rootToSet = HashMap<_Node<T>, Set<T>>();

    // Group elements by their root
    for (final entry in _nodes.entries) {
      final root = _findNode(entry.value);
      rootToSet.putIfAbsent(root, () => <T>{}).add(entry.key);
    }

    // Convert the map values to a list
    return rootToSet.values.toList();
  }

  /// Returns the number of elements in the disjoint set.
  ///
  /// Time complexity: O(1)
  int get size => _nodes.length;

  /// Returns the number of disjoint sets.
  ///
  /// Time complexity: O(n * α(n)), where n is the total number of elements
  int get setCount {
    final Set<_Node<T>> roots = <_Node<T>>{};

    for (final node in _nodes.values) {
      roots.add(_findNode(node));
    }

    return roots.length;
  }

  /// Removes [value] from its set if it exists.
  ///
  /// Returns `true` if the value was found and removed, `false` otherwise.
  ///
  /// If the removed element is a representative (root) of its set, one of the
  /// remaining elements in the set will become the new representative.
  ///
  /// Time complexity: O(n * α(n)), where n is the total number of elements
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.union('A', 'B');
  /// ds.remove('A');
  /// print(ds.connected('A', 'B')); // false
  /// ```
  bool remove(T value) {
    if (!_nodes.containsKey(value)) {
      return false;
    }

    // Check if this element is a representative (root)
    final _Node<T> node = _nodes[value]!;
    final bool isRoot = node.parent == node;

    // If it's a root and has other elements in its set, update their parent pointers
    if (isRoot) {
      // Find all elements in this set
      final Set<T> setElements = getSet(value);

      // If there are other elements in the set, find a new representative
      if (setElements.length > 1) {
        // Remove the current element from the set
        setElements.remove(value);

        // Choose a new root element
        // For deterministic behavior, we'll use the first element in the set
        final T newRoot = setElements.first;

        final _Node<T> newRootNode = _nodes[newRoot]!;

        // Make the new node a root
        newRootNode.parent = newRootNode;
        newRootNode.rank = node.rank; // Preserve rank

        // Update parent pointers for all other elements in the set
        for (final T element in setElements) {
          if (element != newRoot) {
            _nodes[element]!.parent = newRootNode;
          }
        }
      }
    }

    // Remove the node
    _nodes.remove(value);
    return true;
  }

  /// Merges elements that satisfy the provided [predicate].
  ///
  /// The [predicate] function should return `true` for pairs of elements
  /// that should be merged. This is useful for custom equivalence relations.
  ///
  /// **Important note:** This method creates transitive relationships. For example, if
  /// the predicate returns true for (a,b) and (b,c), then a and c will be
  /// in the same set even if the predicate returns false for (a,c).
  ///
  /// For distance-based predicates or other non-transitive relationships,
  /// you may need to use a different approach, such as building a graph and
  /// finding connected components directly.
  ///
  /// Time complexity: O(n² * α(n)), where n is the total number of elements
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<int>();
  /// for (int i = 1; i <= 10; i++) {
  ///   ds.makeSet(i);
  /// }
  /// // Merge numbers with the same parity (odd/even)
  /// ds.mergeIf((a, b) => a % 2 == b % 2);
  /// print(ds.getAllSets()); // Two sets: odd numbers and even numbers
  /// ```
  void mergeIf(bool Function(T, T) predicate) {
    final List<T> elements = _nodes.keys.toList();

    for (int i = 0; i < elements.length; i++) {
      for (int j = i + 1; j < elements.length; j++) {
        final a = elements[i];
        final b = elements[j];

        // Check if these elements should be merged according to predicate
        if (predicate(a, b)) {
          union(a, b);
        }
      }
    }
  }

  /// Converts the disjoint set structure to a JSON-serializable map.
  ///
  /// The resulting map has two keys:
  /// - 'elements': A list of all elements in the structure
  /// - 'sets': A list of sets, where each set is represented as a list of indices
  ///   into the 'elements' list
  ///
  /// Note: This only works correctly if the elements of type T can be properly
  /// serialized to JSON. Custom objects may need to implement `toJson()`.
  ///
  /// Example:
  /// ```dart
  /// final ds = DisjointSet<String>();
  /// ds.makeSet('A');
  /// ds.makeSet('B');
  /// ds.makeSet('C');
  /// ds.union('A', 'B');
  /// final json = ds.toJson();
  /// print(json);
  /// // {
  /// //   'elements': ['A', 'B', 'C'],
  /// //   'sets': [[0, 1], [2]]
  /// // }
  /// ```
  Map<String, dynamic> toJson() {
    final List<T> elements = _nodes.keys.toList();
    final Map<T, int> elementToIndex = <T, int>{};

    // Create index mapping
    for (int i = 0; i < elements.length; i++) {
      elementToIndex[elements[i]] = i;
    }

    // Group elements into sets
    final List<Set<T>> sets = getAllSets();
    final List<List<int>> setIndices = sets.map((set) {
      return set.map((element) => elementToIndex[element]!).toList();
    }).toList();

    return {
      'elements': elements,
      'sets': setIndices,
    };
  }

  /// Creates a DisjointSet from a JSON-serializable map.
  ///
  /// The map should have the format produced by [toJson].
  ///
  /// Note: This only works correctly if the elements of type T can be properly
  /// deserialized from JSON. Custom objects may need special handling.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'elements': ['A', 'B', 'C'],
  ///   'sets': [[0, 1], [2]]
  /// };
  /// final ds = DisjointSet<String>.fromJson(
  ///   json,
  ///   fromJsonT: (dynamic json) => json as String,
  /// );
  /// print(ds.connected('A', 'B')); // true
  /// print(ds.connected('A', 'C')); // false
  /// ```
  factory DisjointSet.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic) fromJsonT,
  }) {
    final DisjointSet<T> result = DisjointSet<T>();

    // Extract elements
    final List<dynamic> elementsJson = json['elements'] as List<dynamic>;
    final List<T> elements = elementsJson.map(fromJsonT).toList();

    // Create singleton sets for all elements
    for (final element in elements) {
      result.makeSet(element);
    }

    // Apply unions based on the sets
    final List<dynamic> setsJson = json['sets'] as List<dynamic>;
    for (final dynamic setJson in setsJson) {
      final List<int> indices = (setJson as List<dynamic>).cast<int>();

      // Union all elements in this set
      for (int i = 1; i < indices.length; i++) {
        final T a = elements[indices[0]];
        final T b = elements[indices[i]];
        result.union(a, b);
      }
    }

    return result;
  }
}

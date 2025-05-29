import 'dart:convert';
import 'package:disjoint_set/disjoint_set.dart';
import 'package:test/test.dart';
import 'point.dart';

void main() {
  group('Basic Operations', () {
    late DisjointSet<String> ds;

    setUp(() {
      ds = DisjointSet<String>();
    });

    test('makeSet creates singleton sets', () {
      // Creating sets
      ds.makeSet('A');
      ds.makeSet('B');
      ds.makeSet('C');

      // Verify set count and size
      expect(ds.size, 3);
      expect(ds.setCount, 3);

      // Verify each element is in its own set
      expect(ds.find('A'), 'A');
      expect(ds.find('B'), 'B');
      expect(ds.find('C'), 'C');
    });

    test('makeSet is idempotent', () {
      // Add the same element multiple times
      ds.makeSet('A');
      ds.makeSet('A');
      ds.makeSet('A');

      // Verify only one set is created
      expect(ds.size, 1);
      expect(ds.setCount, 1);
      expect(ds.getSet('A'), {'A'});
    });

    test('find returns null for non-existent elements', () {
      expect(ds.find('X'), isNull);
    });

    test('find returns representative element', () {
      ds.makeSet('A');
      ds.makeSet('B');
      ds.makeSet('C');

      // Initially each element is its own representative
      expect(ds.find('A'), 'A');
      expect(ds.find('B'), 'B');
      expect(ds.find('C'), 'C');

      // After union, they should share the same representative
      ds.union('A', 'B');
      final rep = ds.find('A');
      expect(ds.find('B'), rep);
      expect(rep == 'A' || rep == 'B',
          isTrue); // Either A or B can be the representative
    });

    test('union merges sets', () {
      // Set up
      ds.makeSet('A');
      ds.makeSet('B');
      ds.makeSet('C');
      ds.makeSet('D');

      // Perform unions
      ds.union('A', 'B');
      ds.union('C', 'D');

      // Verify correct elements are united
      expect(ds.connected('A', 'B'), isTrue);
      expect(ds.connected('C', 'D'), isTrue);
      expect(ds.connected('A', 'C'), isFalse);
      expect(ds.connected('B', 'D'), isFalse);

      // Verify set count
      expect(ds.setCount, 2);

      // Union across sets
      ds.union('B', 'C');

      // Verify all elements are now in the same set
      expect(ds.connected('A', 'D'), isTrue);
      expect(ds.setCount, 1);
    });

    test('union creates new elements if needed', () {
      // Union with non-existent elements
      ds.union('A', 'B');

      // Verify elements were created and united
      expect(ds.size, 2);
      expect(ds.setCount, 1);
      expect(ds.connected('A', 'B'), isTrue);
    });

    test('union is idempotent', () {
      ds.makeSet('A');
      ds.makeSet('B');

      // Union multiple times
      ds.union('A', 'B');
      ds.union('A', 'B');
      ds.union('B', 'A');

      // Verify only one set exists
      expect(ds.setCount, 1);
    });
  });

  group('Set Queries', () {
    late DisjointSet<int> ds;

    setUp(() {
      ds = DisjointSet<int>();
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
    });

    test('connected correctly identifies elements in the same set', () {
      // Elements in the same set
      expect(ds.connected(0, 2), isTrue);
      expect(ds.connected(3, 5), isTrue);
      expect(ds.connected(6, 8), isTrue);

      // Elements in different sets
      expect(ds.connected(0, 3), isFalse);
      expect(ds.connected(3, 6), isFalse);
      expect(ds.connected(0, 9), isFalse);
    });

    test('connected handles non-existent elements', () {
      expect(ds.connected(100, 200), isFalse);
      expect(ds.connected(0, 100), isFalse);
    });

    test('getSet returns all elements in the same set', () {
      // Check sets for each connected component
      expect(ds.getSet(0), unorderedEquals({0, 1, 2}));
      expect(ds.getSet(3), unorderedEquals({3, 4, 5}));
      expect(ds.getSet(6), unorderedEquals({6, 7, 8}));
      expect(ds.getSet(9), unorderedEquals({9}));
    });

    test('getSet returns empty set for non-existent elements', () {
      expect(ds.getSet(100), isEmpty);
    });

    test('getAllSets returns all disjoint sets', () {
      final allSets = ds.getAllSets();

      // Should be 4 sets
      expect(allSets.length, 4);

      // Each set should contain the correct elements
      expect(
          allSets.any((set) => set.length == 3 && set.containsAll({0, 1, 2})),
          isTrue);
      expect(
          allSets.any((set) => set.length == 3 && set.containsAll({3, 4, 5})),
          isTrue);
      expect(
          allSets.any((set) => set.length == 3 && set.containsAll({6, 7, 8})),
          isTrue);
      expect(allSets.any((set) => set.length == 1 && set.contains(9)), isTrue);
    });

    test('getAllSets returns empty list for empty DisjointSet', () {
      final emptyDs = DisjointSet<int>();
      expect(emptyDs.getAllSets(), isEmpty);
    });
  });

  group('Advanced Features', () {
    test('mergeIf combines elements satisfying predicate', () {
      final ds = DisjointSet<int>();

      // Add elements 1-10
      for (int i = 1; i <= 10; i++) {
        ds.makeSet(i);
      }

      // Initially 10 singleton sets
      expect(ds.setCount, 10);

      // Merge numbers with the same parity (odd/even)
      ds.mergeIf((a, b) => a % 2 == b % 2);

      // Should now have 2 sets (odd and even)
      expect(ds.setCount, 2);

      // Verify the sets
      final Set<int> evenSet = ds.getSet(2);
      final Set<int> oddSet = ds.getSet(1);

      expect(evenSet, unorderedEquals({2, 4, 6, 8, 10}));
      expect(oddSet, unorderedEquals({1, 3, 5, 7, 9}));

      // Verify connectivity
      expect(ds.connected(2, 4), isTrue);
      expect(ds.connected(1, 3), isTrue);
      expect(ds.connected(1, 2), isFalse);
    });

    test('mergeIf works with empty sets', () {
      final ds = DisjointSet<int>();
      // Should not throw
      ds.mergeIf((a, b) => a == b);
      expect(ds.setCount, 0);
    });

    test('remove eliminates element from set', () {
      final ds = DisjointSet<String>();

      // Create and unite elements
      ds.makeSet('A');
      ds.makeSet('B');
      ds.makeSet('C');
      ds.union('A', 'B');
      ds.union('B', 'C');

      // Initially all in one set
      expect(ds.getSet('A'), unorderedEquals({'A', 'B', 'C'}));
      expect(ds.size, 3);

      // Remove middle element
      bool result = ds.remove('B');
      expect(result, isTrue);

      // Verify B is gone but A and C remain connected
      expect(ds.size, 2);
      expect(ds.find('B'), isNull);
      expect(ds.connected('A', 'C'), isTrue);
      expect(ds.getSet('A'), unorderedEquals({'A', 'C'}));
    });

    test('remove returns false for non-existent elements', () {
      final ds = DisjointSet<String>();
      ds.makeSet('A');

      bool result = ds.remove('X');
      expect(result, isFalse);
      expect(ds.size, 1);
    });

    test('remove works with representative elements', () {
      final ds = DisjointSet<String>();
      ds.makeSet('A');
      ds.makeSet('B');
      ds.union('A', 'B');

      // Get the representative
      final rep = ds.find('A');

      // Remove the representative
      ds.remove(rep!);

      // Verify the structure is still valid
      expect(ds.size, 1);
      expect(ds.find(rep), isNull);

      // The other element should still exist
      final remaining = rep == 'A' ? 'B' : 'A';
      expect(ds.find(remaining), remaining);
    });
  });

  group('Serialization', () {
    test('toJson/fromJson preserves structure with strings', () {
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

      // Convert to JSON and back
      final jsonMap = ds.toJson();
      final newDs = DisjointSet<String>.fromJson(
        jsonMap,
        fromJsonT: (dynamic json) => json as String,
      );

      // Verify connections are preserved
      expect(newDs.connected('A', 'B'), isTrue);
      expect(newDs.connected('C', 'D'), isTrue);
      expect(newDs.connected('A', 'C'), isFalse);
      expect(newDs.connected('E', 'A'), isFalse);

      // Verify sets match
      expect(newDs.getAllSets().length, 3);
      expect(newDs.getSet('A'), unorderedEquals({'A', 'B'}));
      expect(newDs.getSet('C'), unorderedEquals({'C', 'D'}));
      expect(newDs.getSet('E'), unorderedEquals({'E'}));
    });

    test('toJson/fromJson works with numbers', () {
      final ds = DisjointSet<int>();

      // Create and unite elements
      for (int i = 0; i < 10; i++) {
        ds.makeSet(i);
      }

      ds.union(0, 1);
      ds.union(1, 2);
      ds.union(5, 6);
      ds.union(6, 7);

      // Convert to JSON and back
      final jsonMap = ds.toJson();
      final jsonString = jsonEncode(jsonMap);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final newDs = DisjointSet<int>.fromJson(
        decodedMap,
        fromJsonT: (dynamic json) => json as int,
      );

      // Verify structure
      expect(newDs.size, 10);
      expect(newDs.setCount, 6); // [0,1,2], [3], [4], [5,6,7], [8], [9]
      expect(newDs.connected(0, 2), isTrue);
      expect(newDs.connected(5, 7), isTrue);
      expect(newDs.connected(0, 5), isFalse);
    });

    test('toJson/fromJson with empty DisjointSet', () {
      final ds = DisjointSet<String>();
      final jsonMap = ds.toJson();

      final newDs = DisjointSet<String>.fromJson(
        jsonMap,
        fromJsonT: (dynamic json) => json as String,
      );

      expect(newDs.size, 0);
      expect(newDs.setCount, 0);
      expect(newDs.getAllSets(), isEmpty);
    });
  });

  group('Performance Characteristics', () {
    test('operations should be efficient with large datasets', () {
      // Skip this test in everyday CI runs
      // if (skipPerformanceTests) return;

      final stopwatch = Stopwatch();
      final int n = 10000;

      final ds = DisjointSet<int>();

      // Measure makeSet
      stopwatch.start();
      for (int i = 0; i < n; i++) {
        ds.makeSet(i);
      }
      stopwatch.stop();
      final makeSetTime = stopwatch.elapsedMilliseconds;

      // The time should be reasonable for 10,000 elements
      expect(makeSetTime, lessThan(500)); // Very generous limit

      // Measure union
      stopwatch.reset();
      stopwatch.start();
      for (int i = 0; i < n - 1; i++) {
        ds.union(i, i + 1);
      }
      stopwatch.stop();
      final unionTime = stopwatch.elapsedMilliseconds;

      // Union with path compression should be efficient
      expect(unionTime, lessThan(500)); // Very generous limit

      // Measure find (which benefits from path compression)
      stopwatch.reset();
      stopwatch.start();
      for (int i = 0; i < 100; i++) {
        ds.find(i * 100); // Spread out the finds
      }
      stopwatch.stop();
      final findTime = stopwatch.elapsedMilliseconds;

      // Find with path compression should be very fast
      expect(findTime, lessThan(50)); // Very generous limit

      // Verify correctness
      expect(ds.setCount, 1);
      expect(ds.connected(0, n - 1), isTrue);
    });
  });

  group('Error Handling and Edge Cases', () {
    test('empty DisjointSet handles all operations gracefully', () {
      final ds = DisjointSet<String>();

      // Size and count should be 0
      expect(ds.size, 0);
      expect(ds.setCount, 0);

      // Find should return null
      expect(ds.find('A'), isNull);

      // Connected should return false
      expect(ds.connected('A', 'B'), isFalse);

      // GetSet should return empty set
      expect(ds.getSet('A'), isEmpty);

      // GetAllSets should return empty list
      expect(ds.getAllSets(), isEmpty);

      // Remove should return false
      expect(ds.remove('A'), isFalse);

      // MergeIf should do nothing
      ds.mergeIf((a, b) => true);
      expect(ds.size, 0);
    });

    test('operations after removal remain consistent', () {
      final ds = DisjointSet<String>();

      // Create and unite
      ds.makeSet('A');
      ds.makeSet('B');
      ds.makeSet('C');
      ds.union('A', 'B');
      ds.union('B', 'C');

      // Remove B
      ds.remove('B');

      // A and C should still be connected
      expect(ds.connected('A', 'C'), isTrue);

      // Add B back
      ds.makeSet('B');

      // B should not be connected to A or C
      expect(ds.connected('A', 'B'), isFalse);
      expect(ds.connected('B', 'C'), isFalse);

      // Unite B with A
      ds.union('A', 'B');

      // All should be connected now
      expect(ds.connected('A', 'B'), isTrue);
      expect(ds.connected('B', 'C'), isTrue);
      expect(ds.setCount, 1);
    });

    test('handles self-union', () {
      final ds = DisjointSet<String>();
      ds.makeSet('A');

      // Union with self should be a no-op
      ds.union('A', 'A');

      expect(ds.size, 1);
      expect(ds.setCount, 1);
      expect(ds.getSet('A'), {'A'});
    });
  });

  group('Custom Object Support', () {
    test('works with custom objects', () {
      final ds = DisjointSet<Point>();

      final p1 = Point(1, 2);
      final p2 = Point(2, 3);
      final p3 = Point(10, 10);
      final p4 = Point(11, 12);

      // Add points
      ds.makeSet(p1);
      ds.makeSet(p2);
      ds.makeSet(p3);
      ds.makeSet(p4);

      // Union close points
      ds.union(p1, p2); // Close
      ds.union(p3, p4); // Close

      // Verify connections
      expect(ds.connected(p1, p2), isTrue);
      expect(ds.connected(p3, p4), isTrue);
      expect(ds.connected(p1, p3), isFalse);

      // Verify sets
      expect(ds.getSet(p1), unorderedEquals({p1, p2}));
      expect(ds.getSet(p3), unorderedEquals({p3, p4}));
      expect(ds.setCount, 2);
    });

    test('serialization with custom objects', () {
      final ds = DisjointSet<Point>();

      final p1 = Point(1, 2);
      final p2 = Point(2, 3);
      final p3 = Point(10, 10);

      // Add and unite
      ds.makeSet(p1);
      ds.makeSet(p2);
      ds.makeSet(p3);
      ds.union(p1, p2);

      // Manual serialization for custom objects
      final jsonMap = ds.toJson();
      final customJson = {
        'elements': (jsonMap['elements'] as List<dynamic>)
            .map((p) => (p as Point).toJson())
            .toList(),
        'sets': jsonMap['sets'],
      };

      final jsonString = jsonEncode(customJson);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;

      // Manual deserialization for custom objects
      final customDecodedJson = {
        'elements': (decodedMap['elements'] as List<dynamic>)
            .map((json) => Point.fromJson(json))
            .toList(),
        'sets': decodedMap['sets'],
      };

      final newDs = DisjointSet<Point>.fromJson(
        customDecodedJson,
        fromJsonT: (dynamic json) => json as Point,
      );

      // Verify structure is preserved
      expect(newDs.size, 3);
      expect(newDs.setCount, 2);
      expect(newDs.connected(Point(1, 2), Point(2, 3)), isTrue);
      expect(newDs.connected(Point(1, 2), Point(10, 10)), isFalse);
    });

    test('point connectivity in a grid structure', () {
      // NOTE: This test demonstrates why using mergeIf() for distance-based
      // clustering can lead to unexpected results due to transitive connections.
      // In real applications, consider graph algorithms for such use cases.
      
      final ds = DisjointSet<Point>();
      
      // Create a small 3x3 grid of points for clarity
      final grid = List.generate(3, (x) => 
        List.generate(3, (y) => Point(x, y)));
      
      // Add all points to the disjoint set
      for (final row in grid) {
        for (final point in row) {
          ds.makeSet(point);
        }
      }
      
      // Initially, all points are in their own sets
      expect(ds.size, 9);
      expect(ds.setCount, 9);
      
      // Create a grid path with clear connectivity:
      //
      // (0,0)-(1,0)-(2,0)
      //        |
      // (0,1)-(1,1)-(2,1)
      //        |
      // (0,2)-(1,2)-(2,2)
      
      // First, create all horizontal connections (rows)
      ds.union(grid[0][0], grid[1][0]); // (0,0) - (1,0)
      ds.union(grid[1][0], grid[2][0]); // (1,0) - (2,0)
      
      ds.union(grid[0][1], grid[1][1]); // (0,1) - (1,1)
      ds.union(grid[1][1], grid[2][1]); // (1,1) - (2,1)
      
      ds.union(grid[0][2], grid[1][2]); // (0,2) - (1,2)
      ds.union(grid[1][2], grid[2][2]); // (1,2) - (2,2)
      
      // Then create vertical connections (columns)
      ds.union(grid[1][0], grid[1][1]); // (1,0) - (1,1)
      ds.union(grid[1][1], grid[1][2]); // (1,1) - (1,2)
      
      // Verify horizontal connectivity (rows)
      expect(ds.connected(grid[0][0], grid[2][0]), isTrue, 
          reason: "(0,0) should connect to (2,0) along the top row");
      expect(ds.connected(grid[0][1], grid[2][1]), isTrue,
          reason: "(0,1) should connect to (2,1) along the middle row");
      expect(ds.connected(grid[0][2], grid[2][2]), isTrue,
          reason: "(0,2) should connect to (2,2) along the bottom row");
      
      // Verify vertical connectivity through the middle column
      expect(ds.connected(grid[1][0], grid[1][2]), isTrue,
          reason: "(1,0) should connect to (1,2) through the middle column");
      
      // Verify full grid connectivity
      expect(ds.connected(grid[0][0], grid[2][2]), isTrue,
          reason: "(0,0) should connect to (2,2) through the grid path");
      expect(ds.connected(grid[2][0], grid[0][2]), isTrue,
          reason: "(2,0) should connect to (0,2) through the grid path");
      
      // All points should be connected in a single set since we created a connected grid
      expect(ds.setCount, 1, reason: "All points should be in one connected set");
      expect(ds.size, 9, reason: "There should be 9 points in the grid");
      
      // Test distance-based checks using the isCloseTo helper
      // For adjacent points (distance = 1.0)
      expect(grid[0][0].isCloseTo(grid[1][0], 1.5), isTrue,
          reason: "Adjacent points should be within distance 1.5");
      
      // For diagonal points (distance = sqrt(2) ≈ 1.414)
      expect(grid[0][0].isCloseTo(grid[1][1], 1.5), isTrue,
          reason: "Diagonal points should be within distance 1.5");
      
      // For distant points (distance = sqrt(8) ≈ 2.828 > 2.5)
      expect(grid[0][0].isCloseTo(grid[2][2], 2.5), isFalse,
          reason: "Distant points should NOT be within distance 2.5");
    });
  });
}

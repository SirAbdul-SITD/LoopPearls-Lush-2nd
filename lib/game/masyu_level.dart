// lib/game/masyu_level.dart
import 'dart:math';

/// Masyu ("Loop Pearls"). Draw a single closed loop through cell centers that:
///  - passes STRAIGHT through every white pearl, and turns in at least one of
///    the two adjacent cells along the loop;
///  - TURNS on every black pearl, and goes straight in both cells immediately
///    before and after it.
///
/// Generation: take a Hamiltonian cycle on an even n×n grid (always exists),
/// then classify loop vertices and place white/black pearls only where the
/// loop already satisfies the corresponding rule. The loop is the solution.
class MasyuLevel {
  final int index;
  final int n;             // even
  final String difficulty;
  final List<int> cycle;   // ordered cell indices forming the loop
  final Map<int, int> pearls; // cell -> 1 white, 2 black
  MasyuLevel({
    required this.index,
    required this.n,
    required this.difficulty,
    required this.cycle,
    required this.pearls,
  });

  /// Solution loop as undirected edges between adjacent cells (canonical key).
  Set<String> solutionEdges() {
    final s = <String>{};
    for (int i = 0; i < cycle.length; i++) {
      final a = cycle[i], b = cycle[(i + 1) % cycle.length];
      s.add(a < b ? '$a-$b' : '$b-$a');
    }
    return s;
  }
}

class LevelGenerator {
  static MasyuLevel generate(int levelIndex) {
    int n;
    String difficulty;
    if (levelIndex < 50) {
      n = 6; difficulty = 'Easy';
    } else if (levelIndex < 100) {
      n = 8; difficulty = 'Medium';
    } else {
      n = 10; difficulty = 'Hard';
    }
    final rng = Random(levelIndex * 733 + levelIndex * 17 + 7);
    for (int t = 0; t < 80; t++) {
      final res = _build(levelIndex, n, difficulty, Random(rng.nextInt(1 << 31)));
      if (res != null) return res;
    }
    return _build(levelIndex, n, difficulty, Random(1))!;
  }

  /// Hamiltonian cycle on n×n grid (n even). Corridor down column 0; snake the
  /// remaining columns; close back up column 0.
  static List<List<int>> _hamCycle(int n) {
    final cyc = <List<int>>[];
    for (int c = 0; c < n; c++) cyc.add([0, c]);
    for (int c = n - 1; c >= 1; c--) {
      if ((n - 1 - c) % 2 == 0) {
        for (int r = 1; r < n; r++) cyc.add([r, c]);
      } else {
        for (int r = n - 1; r >= 1; r--) cyc.add([r, c]);
      }
    }
    for (int r = n - 1; r >= 1; r--) cyc.add([r, 0]);
    return cyc;
  }

  static MasyuLevel? _build(int index, int n, String diff, Random rng) {
    final cyc2 = _hamCycle(n);
    final cycle = cyc2.map((rc) => rc[0] * n + rc[1]).toList();
    final L = cycle.length;
    if (cycle.toSet().length != n * n) return null;

    final pearls = <int, int>{};
    List<int> dir(int a, int b) => [b ~/ n - a ~/ n, b % n - a % n];
    bool eq(List<int> x, List<int> y) => x[0] == y[0] && x[1] == y[1];

    for (int i = 0; i < L; i++) {
      final prev = cycle[(i - 1 + L) % L];
      final cur = cycle[i];
      final nxt = cycle[(i + 1) % L];
      final p2 = cycle[(i - 2 + L) % L];
      final n2 = cycle[(i + 2) % L];
      final d1 = dir(prev, cur);
      final d2 = dir(cur, nxt);
      final d0 = dir(p2, prev);
      final d3 = dir(nxt, n2);
      final straight = eq(d1, d2);
      if (straight) {
        // white candidate: a turn at prev OR at next
        if (!eq(d0, d1) || !eq(d3, d2)) {
          if (rng.nextDouble() < 0.32) pearls[cur] = 1;
        }
      } else {
        // black candidate: straight before and after the turn
        if (eq(d0, d1) && eq(d3, d2)) {
          if (rng.nextDouble() < 0.45) pearls[cur] = 2;
        }
      }
    }
    final whites = pearls.values.where((v) => v == 1).length;
    final blacks = pearls.values.where((v) => v == 2).length;
    if (whites + blacks < 4 || whites == 0) return null;

    return MasyuLevel(
      index: index, n: n, difficulty: diff, cycle: cycle, pearls: pearls,
    );
  }
}

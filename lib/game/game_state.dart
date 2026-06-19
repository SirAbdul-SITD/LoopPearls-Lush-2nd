// lib/game/game_state.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

/// Flood-It. The board fills from the top-left cell: pick a color and the
/// connected region of the start color expands to absorb adjacent matching
/// cells. Flood the entire board to one color within the move limit.
///
/// The move budget is derived from a greedy solve of the generated board
/// (greedy "pick the color that captures the most cells" needs at most a
/// known number of moves), then given some slack — so the level is always
/// winnable within the limit.
class GameState extends ChangeNotifier {
  int currentLevelIndex = 0;
  late int size;
  late int colorCount;
  late String difficulty;
  late List<int> cells; // color index per cell
  int moves = 0;
  int moveLimit = 0;
  bool isComplete = false;
  bool failed = false;
  int stars = 0;
  bool initialized = false;

  void loadLevel(int index) {
    currentLevelIndex = index;
    if (index < 50) {
      size = 8; colorCount = 4; difficulty = 'Easy';
    } else if (index < 100) {
      size = 11; colorCount = 5; difficulty = 'Medium';
    } else {
      size = 14; colorCount = 6; difficulty = 'Hard';
    }

    final rng = Random(index * 5851 + index * 23 + 11);
    cells = List<int>.generate(size * size, (_) => rng.nextInt(colorCount));

    // compute greedy solution length, then allow slack
    final greedy = _greedySolve(List<int>.from(cells));
    moveLimit = greedy + (difficulty == 'Easy'
        ? 3
        : difficulty == 'Medium'
            ? 4
            : 5);

    moves = 0;
    isComplete = false;
    failed = false;
    stars = 0;
    initialized = true;
    notifyListeners();
  }

  List<int> _neighbors(int i, int s) {
    final r = i ~/ s, c = i % s;
    return [
      if (r > 0) i - s,
      if (r < s - 1) i + s,
      if (c > 0) i - 1,
      if (c < s - 1) i + 1,
    ];
  }

  /// Region connected to cell 0 sharing its color.
  Set<int> _region(List<int> g) {
    final start = g[0];
    final seen = <int>{0};
    final stack = [0];
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      for (final n in _neighbors(cur, size)) {
        if (!seen.contains(n) && g[n] == start) {
          seen.add(n);
          stack.add(n);
        }
      }
    }
    return seen;
  }

  void _apply(List<int> g, int color) {
    final region = _region(g);
    for (final i in region) {
      g[i] = color;
    }
  }

  bool _allSame(List<int> g) {
    final first = g[0];
    return g.every((c) => c == first);
  }

  /// Greedy: repeatedly pick the color that grows the region most.
  int _greedySolve(List<int> g) {
    int count = 0;
    int guard = 0;
    while (!_allSame(g) && guard < size * size * 2) {
      guard++;
      final cur = g[0];
      int best = -1, bestGain = -1;
      for (int color = 0; color < colorCount; color++) {
        if (color == cur) continue;
        final copy = List<int>.from(g);
        _apply(copy, color);
        final gain = _region(copy).length;
        if (gain > bestGain) {
          bestGain = gain;
          best = color;
        }
      }
      _apply(g, best);
      count++;
    }
    return count;
  }

  int get floodedCount => _region(cells).length;

  void pick(int color) {
    if (isComplete || failed) return;
    if (color == cells[0]) return;
    _apply(cells, color);
    moves++;
    AudioManager.instance.playFlood();
    if (_allSame(cells)) {
      isComplete = true;
      stars = _calcStars();
      AudioManager.instance.playComplete();
      Preferences.instance.saveLevelResult(currentLevelIndex, stars);
    } else if (moves >= moveLimit) {
      failed = true;
    }
    notifyListeners();
  }

  int get movesLeft => moveLimit - moves;

  int _calcStars() {
    final left = movesLeft;
    if (left >= 3) return 3;
    if (left >= 1) return 2;
    return 1;
  }

  void restartLevel() => loadLevel(currentLevelIndex);

  void nextLevel() {
    if (currentLevelIndex < 149) loadLevel(currentLevelIndex + 1);
  }
}

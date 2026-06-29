// lib/game/game_state.dart
import 'package:flutter/material.dart';
import 'masyu_level.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

/// Player draws loop segments between adjacent cell centers. Each undirected
/// edge is absent, drawn, or crossed. Win when the drawn edges exactly match
/// the solution loop.
class GameState extends ChangeNotifier {
  late MasyuLevel level;
  final Map<String, int> edges = {}; // "a-b" -> 1 drawn, 2 crossed
  late Set<String> _solution;
  int moves = 0;
  bool isComplete = false;
  int stars = 0;
  int currentLevelIndex = 0;
  bool initialized = false;

  int get n => level.n;

  void loadLevel(int index) {
    currentLevelIndex = index;
    level = LevelGenerator.generate(index);
    _solution = level.solutionEdges();
    edges.clear();
    moves = 0;
    isComplete = false;
    stars = 0;
    initialized = true;
    notifyListeners();
  }

  int get parMoves => _solution.length;

  String key(int a, int b) => a < b ? '$a-$b' : '$b-$a';
  int edgeState(int a, int b) => edges[key(a, b)] ?? 0;

  bool adjacent(int a, int b) {
    final dr = (a ~/ n - b ~/ n).abs();
    final dc = (a % n - b % n).abs();
    return dr + dc == 1;
  }

  void tapEdge(int a, int b) {
    if (isComplete || !adjacent(a, b)) return;
    final k = key(a, b);
    final cur = edges[k] ?? 0;
    final next = (cur + 1) % 3;
    if (next == 0) {
      edges.remove(k);
    } else {
      edges[k] = next;
    }
    moves++;
    AudioManager.instance.playDraw();
    _check();
    notifyListeners();
  }

  int drawnDegree(int cell) {
    int d = 0;
    for (final nb in _nbrs(cell)) {
      if (edgeState(cell, nb) == 1) d++;
    }
    return d;
  }

  List<int> _nbrs(int i) {
    final r = i ~/ n, c = i % n;
    return [
      if (r > 0) i - n,
      if (r < n - 1) i + n,
      if (c > 0) i - 1,
      if (c < n - 1) i + 1,
    ];
  }

  int get pearlCount => level.pearls.length;

  void _check() {
    final drawn = <String>{};
    edges.forEach((k, v) {
      if (v == 1) drawn.add(k);
    });
    if (drawn.length != _solution.length) return;
    for (final e in _solution) {
      if (!drawn.contains(e)) return;
    }
    isComplete = true;
    stars = _calcStars();
    AudioManager.instance.playComplete();
    Preferences.instance.saveLevelResult(currentLevelIndex, stars);
  }

  int _calcStars() {
    if (moves <= parMoves) return 3;
    if (moves <= (parMoves * 1.8).round()) return 2;
    return 1;
  }

  void restartLevel() {
    edges.clear();
    moves = 0;
    isComplete = false;
    stars = 0;
    notifyListeners();
  }

  void nextLevel() {
    if (currentLevelIndex < 149) loadLevel(currentLevelIndex + 1);
  }
}

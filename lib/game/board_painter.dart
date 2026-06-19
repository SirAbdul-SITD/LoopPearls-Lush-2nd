// lib/game/board_painter.dart
import 'package:flutter/material.dart';
import 'game_state.dart';
import '../utils/constants.dart';

class BoardPainter extends CustomPainter {
  final GameState st;
  final Set<int> region;
  BoardPainter(this.st, this.region);

  @override
  void paint(Canvas canvas, Size size) {
    final s = st.size;
    final cell = size.width / s;
    for (int i = 0; i < s * s; i++) {
      final r = i ~/ s, c = i % s;
      final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
      final color = kHues[st.cells[i] % kHues.length];
      canvas.drawRect(rect.deflate(0.5), Paint()..color = color);
      if (region.contains(i)) {
        // subtle inner highlight for the flooded region
        canvas.drawRect(
            rect.deflate(cell * 0.30),
            Paint()..color = Colors.white.withOpacity(0.18));
      }
    }
    // origin marker (top-left)
    canvas.drawRect(
        Rect.fromLTWH(0, 0, cell, cell),
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}

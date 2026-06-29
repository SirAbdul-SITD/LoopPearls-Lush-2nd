// lib/game/board_painter.dart
import 'package:flutter/material.dart';
import 'game_state.dart';
import '../utils/constants.dart';

class BoardPainter extends CustomPainter {
  final GameState st;
  BoardPainter(this.st);

  @override
  void paint(Canvas canvas, Size size) {
    final n = st.n;
    final cell = size.width / n;
    Offset ctr(int i) =>
        Offset((i % n) * cell + cell / 2, (i ~/ n) * cell + cell / 2);

    // faint grid
    final gl = Paint()
      ..color = kBorder.withOpacity(0.4)
      ..strokeWidth = 1;
    for (int i = 0; i <= n; i++) {
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), gl);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), gl);
    }

    // crossed edges
    st.edges.forEach((k, state) {
      if (state != 2) return;
      final p = k.split('-');
      final mid = (ctr(int.parse(p[0])) + ctr(int.parse(p[1]))) / 2;
      final cross = Paint()
        ..color = kCross
        ..strokeWidth = 2;
      const s = 5.0;
      canvas.drawLine(mid + const Offset(-s, -s), mid + const Offset(s, s), cross);
      canvas.drawLine(mid + const Offset(s, -s), mid + const Offset(-s, s), cross);
    });

    // drawn loop
    final glow = Paint()
      ..color = kLine.withOpacity(0.4)
      ..strokeWidth = cell * 0.18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final line = Paint()
      ..color = kLine
      ..strokeWidth = cell * 0.08
      ..strokeCap = StrokeCap.round;
    st.edges.forEach((k, state) {
      if (state != 1) return;
      final p = k.split('-');
      final a = ctr(int.parse(p[0])), b = ctr(int.parse(p[1]));
      canvas.drawLine(a, b, glow);
      canvas.drawLine(a, b, line);
    });

    // center dots
    for (int i = 0; i < n * n; i++) {
      canvas.drawCircle(ctr(i), cell * 0.04, Paint()..color = kDot);
    }

    // pearls
    final radius = cell * 0.30;
    st.level.pearls.forEach((cell, kind) {
      final c = ctr(cell);
      if (kind == 1) {
        canvas.drawCircle(c, radius, Paint()..color = kPearlWhite);
        canvas.drawCircle(
            c,
            radius,
            Paint()
              ..color = kPearlWhiteE
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
      } else {
        canvas.drawCircle(c, radius, Paint()..color = kPearlBlack);
        canvas.drawCircle(
            c,
            radius,
            Paint()
              ..color = kPearlBlackE
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
      }
    });
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}

// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import '../game/board_painter.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelIndex;
  const GameScreen({super.key, required this.levelIndex});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vc;
  late final Animation<double> _va;

  @override
  void initState() {
    super.initState();
    _vc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _va = CurvedAnimation(parent: _vc, curve: Curves.elasticOut);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GameState>().loadLevel(widget.levelIndex));
  }

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Consumer<GameState>(builder: (ctx, st, _) {
        if (!st.initialized) {
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (st.isComplete && !_vc.isCompleted) {
          _vc.forward();
          if (Preferences.instance.isVibrationEnabled()) {
            HapticFeedback.heavyImpact();
          }
        }
        final region = st.floodedCount;
        final total = st.size * st.size;
        return Stack(children: [
          SafeArea(
            child: Column(children: [
              _hud(st),
              const SizedBox(height: 4),
              Text('$region / $total CELLS FLOODED',
                  style: techno(11, color: kTextDim, letterSpacing: 2)),
              Expanded(child: Center(child: _board(st))),
              const SizedBox(height: 8),
              _palette(st),
              const SizedBox(height: 10),
              _bottomBar(st),
              const SizedBox(height: 12),
            ]),
          ),
          if (st.isComplete) _victory(st),
          if (st.failed && !st.isComplete) _failOverlay(st),
        ]);
      }),
    );
  }

  Widget _hud(GameState st) {
    final dc = st.difficulty == 'Easy'
        ? kEasyColor
        : st.difficulty == 'Medium'
            ? kMediumColor
            : kHardColor;
    final low = st.movesLeft <= 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorder)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kTextDim, size: 16),
          ),
        ),
        const Spacer(),
        Column(children: [
          Text('LEVEL ${st.currentLevelIndex + 1}',
              style: techno(14, letterSpacing: 3)),
          Text(st.difficulty.toUpperCase(),
              style: techno(10, color: dc, letterSpacing: 2)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${st.movesLeft}',
              style: techno(18,
                  color: low ? kHardColor : kAccent,
                  weight: FontWeight.w900)),
          Text('MOVES LEFT',
              style: techno(8, color: kTextDim, letterSpacing: 1.5)),
        ]),
      ]),
    );
  }

  Widget _board(GameState st) {
    final size = MediaQuery.of(context).size;
    final boardSize = (size.width - 28).clamp(0.0, size.height * 0.52);
    return Container(
      width: boardSize + 10,
      height: boardSize + 10,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: CustomPaint(
          size: Size(boardSize, boardSize),
          painter: BoardPainter(st, st.isComplete ? <int>{} : _regionOf(st)),
        ),
      ),
    );
  }

  Set<int> _regionOf(GameState st) {
    // mirror of state._region for highlighting (read-only)
    final s = st.size;
    final start = st.cells[0];
    final seen = <int>{0};
    final stack = [0];
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final r = cur ~/ s, c = cur % s;
      for (final n in [
        if (r > 0) cur - s,
        if (r < s - 1) cur + s,
        if (c > 0) cur - 1,
        if (c < s - 1) cur + 1,
      ]) {
        if (!seen.contains(n) && st.cells[n] == start) {
          seen.add(n);
          stack.add(n);
        }
      }
    }
    return seen;
  }

  Widget _palette(GameState st) {
    final current = st.cells.isNotEmpty ? st.cells[0] : -1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < st.colorCount; i++)
          GestureDetector(
            onTap: () {
              if (Preferences.instance.isVibrationEnabled()) {
                HapticFeedback.selectionClick();
              }
              st.pick(i);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kHues[i],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: current == i ? Colors.white : Colors.transparent,
                    width: 3),
                boxShadow: current == i
                    ? [BoxShadow(color: kHues[i].withOpacity(0.6), blurRadius: 12)]
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _bottomBar(GameState st) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionBtn(Icons.refresh_rounded, 'RESTART', () {
            _vc.reset();
            st.restartLevel();
          }),
          const SizedBox(width: 24),
          _actionBtn(Icons.grid_view_rounded, 'LEVELS', () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const LevelSelectScreen()));
          }),
        ],
      );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: kTextDim, size: 16),
            const SizedBox(width: 6),
            Text(label, style: techno(10, color: kTextDim, letterSpacing: 2)),
          ]),
        ),
      );

  Widget _failOverlay(GameState st) => Container(
        color: Colors.black.withOpacity(0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kHardColor.withOpacity(0.5), width: 1.5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.format_color_reset_rounded,
                  color: kHardColor, size: 42),
              const SizedBox(height: 14),
              Text('OUT OF MOVES',
                  style: techno(17,
                      color: kHardColor,
                      weight: FontWeight.w900,
                      letterSpacing: 3)),
              const SizedBox(height: 8),
              Text('${st.floodedCount} / ${st.size * st.size} flooded',
                  style: techno(11, color: kTextDim, letterSpacing: 1)),
              const SizedBox(height: 22),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _vBtn('LEVELS', Icons.grid_view_rounded, false, () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen()));
                }),
                const SizedBox(width: 10),
                _vBtn('RETRY', Icons.refresh_rounded, true,
                    () => st.restartLevel()),
              ]),
            ]),
          ),
        ),
      );

  Widget _victory(GameState st) => Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: ScaleTransition(
            scale: _va,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAccent.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: kAccent.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 4)
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kAccent.withOpacity(0.12),
                    border: Border.all(color: kAccent, width: 2),
                  ),
                  child: const Icon(Icons.palette_rounded,
                      color: kAccent, size: 28),
                ),
                const SizedBox(height: 16),
                Text('BOARD CONQUERED',
                    style: techno(15,
                        color: kAccent,
                        weight: FontWeight.w900,
                        letterSpacing: 3)),
                const SizedBox(height: 6),
                Text('${st.moves} MOVES · ${st.movesLeft} TO SPARE',
                    style: techno(11, color: kTextDim, letterSpacing: 2)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < st.stars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: i < st.stars ? kStarOn : kStarOff,
                              size: 36,
                            ),
                          )),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: _vBtn('REPLAY', Icons.refresh_rounded, false, () {
                    _vc.reset();
                    st.restartLevel();
                  })),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _vBtn('NEXT', Icons.arrow_forward_rounded, true,
                          () {
                    _vc.reset();
                    if (st.currentLevelIndex < 149) {
                      st.nextLevel();
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const LevelSelectScreen()));
                    }
                  })),
                ]),
              ]),
            ),
          ),
        ),
      );

  Widget _vBtn(String label, IconData icon, bool primary, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF2FA877), Color(0xFF6CE5B1)])
                : null,
            color: primary ? null : kBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: primary ? kAccent.withOpacity(0.5) : kBorder),
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: primary ? kBg : Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: techno(12,
                        color: primary ? kBg : kTextPrimary, letterSpacing: 2)),
              ]),
        ),
      );
}

# Loop Pearls — Masyu Logic

Draw a single closed loop that passes straight through white pearls (with a turn beside them) and turns on black pearls (going straight on both sides). 150 levels (6×6 / 8×8 / 10×10).

## Run
```
flutter pub get
flutter run
```

## Guaranteed-solvable generation
A Hamiltonian cycle is built on an even-sized grid (a grid Hamiltonian cycle requires at least one even side, so even boards are used). Each loop vertex is classified, and white/black pearls are placed only where the loop already satisfies that pearl's rule. The loop is therefore a valid solution. Validated: 240/240 even boards.

## Structure
- `lib/game/masyu_level.dart` — even-n Hamiltonian cycle, pearl classification, `solutionEdges()`
- `lib/game/game_state.dart` — tap edges (draw/cross/clear), win when drawn edges == solution loop
- `lib/game/board_painter.dart` — glowing jade loop, white/black pearl tokens, crossed-edge marks
- `lib/screens/` — home, level select, game (with pearl legend), settings
- `assets/music|sounds/` — ambient tracks + draw/complete SFX
- `store/` — icon, feature graphic, listing, privacy policy

## Notes
- Run `flutter create .` once, then set your own `applicationId`.
- The bundled WAV music keeps the Play Store download above 30 MB.

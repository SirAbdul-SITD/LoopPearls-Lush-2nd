// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── Huecraft palette: charcoal + vivid swatch set ──────────────────────
const Color kBg          = Color(0xFF14161C);
const Color kSurface     = Color(0xFF1F232E);
const Color kBorder      = Color(0xFF333A4A);
const Color kAccent      = Color(0xFF6CE5B1);
const Color kTextPrimary = Color(0xFFEDF1F7);
const Color kTextDim     = Color(0xFF8791A4);

const Color kStarOn  = Color(0xFFFFD54F);
const Color kStarOff = Color(0xFF262C38);

const Color kEasyColor   = Color(0xFF6CE5B1);
const Color kMediumColor = Color(0xFF5AA9FF);
const Color kHardColor   = Color(0xFFFF7043);

// The flood colors (up to 6 used depending on difficulty)
const List<Color> kHues = [
  Color(0xFFFF5D5D), // red
  Color(0xFFFFB13D), // orange
  Color(0xFFFFE14D), // yellow
  Color(0xFF5CD98A), // green
  Color(0xFF4FB0FF), // blue
  Color(0xFFB07BFF), // purple
];

const int kTotalLevels = 150;

TextStyle techno(double size,
        {Color color = kTextPrimary,
        FontWeight weight = FontWeight.bold,
        double letterSpacing = 1.5}) =>
    TextStyle(
        fontSize: size, color: color, fontWeight: weight,
        letterSpacing: letterSpacing);

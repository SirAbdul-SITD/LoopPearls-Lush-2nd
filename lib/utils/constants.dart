// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── Loop Pearls palette: ink wash + jade loop + pearl tokens ───────────
const Color kBg          = Color(0xFF0F1518);
const Color kSurface     = Color(0xFF182227);
const Color kBorder      = Color(0xFF2A3A40);
const Color kAccent      = Color(0xFF4FD6B8);
const Color kDot         = Color(0xFF35494F);
const Color kLine        = Color(0xFF5FE6C6); // drawn loop
const Color kCross       = Color(0xFF3A4F55);
const Color kPearlWhite  = Color(0xFFF2F6F5);
const Color kPearlWhiteE = Color(0xFF9FB2B0);
const Color kPearlBlack  = Color(0xFF1A2226);
const Color kPearlBlackE = Color(0xFF44585E);
const Color kTextPrimary = Color(0xFFEAF4F1);
const Color kTextDim     = Color(0xFF7C9893);

const Color kStarOn  = Color(0xFFFFD54F);
const Color kStarOff = Color(0xFF1E2C30);

const Color kEasyColor   = Color(0xFF4FD6B8);
const Color kMediumColor = Color(0xFF5AA9FF);
const Color kHardColor   = Color(0xFFFF7043);

const int kTotalLevels = 150;

TextStyle techno(double size,
        {Color color = kTextPrimary,
        FontWeight weight = FontWeight.bold,
        double letterSpacing = 1.5}) =>
    TextStyle(
        fontSize: size, color: color, fontWeight: weight,
        letterSpacing: letterSpacing);

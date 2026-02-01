import 'package:flutter/material.dart';

/// Central color palette for the app (profile screen theme).
/// Use these or Theme.of(context).colorScheme / theme extensions for consistency.
abstract class AppColors {
  AppColors._();

  static const Color headerViolet = Color.fromARGB(255, 55, 16, 128);
  static const Color accentViolet = Color(0xFFB39DFF);
  static const Color surfaceBlack = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  /// Border color for cards/inputs in dark theme
  static const Color borderDark = Color(0xFF2A2A3E);

  /// Input border when enabled (dark)
  static const Color inputBorderDark = Color(0xFF37346E);

  /// Unselected / secondary text (dark)
  static const Color unselectedDark = Color(0xFF6967A6);

  /// Chart area background (paper/cream for readability)
  static const Color chartBackground = Color(0xFFF5F0E6);
}

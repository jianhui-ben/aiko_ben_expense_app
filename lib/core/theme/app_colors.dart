import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7F6F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0EEE9);

  static const primary = Color(0xFF4F46E5);
  static const primaryContainer = Color(0xFFEEF2FF);
  static const secondary = Color(0xFF059669);
  static const error = Color(0xFFDC2626);

  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const textTertiary = Color(0xFFA8A29E);

  static const border = Color(0xFFE7E5E4);
  static const categoryAccent = Color(0xFF818CF8);

  /// Flat, tasteful palette for categorical charts (donut slices, ranked
  /// category rows). Cycled by index, brand indigo first.
  static const List<Color> chartPalette = [
    Color(0xFF4F46E5), // indigo (primary)
    Color(0xFF059669), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
    Color(0xFF0EA5E9), // sky
    Color(0xFF8B5CF6), // violet
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
  ];

  static Color chartColorAt(int index) =>
      chartPalette[index % chartPalette.length];
}

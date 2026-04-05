import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFA192F8); 
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFD6D6F5); 
  static const Color lightSurface = Colors.white;
  static const Color lightCardBg = Color(0xFFF9F9FB);
  static const Color lightTextPrimary = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1E1E2C);
  static const Color darkSurface = Color(0xFF2D2D44);
  static const Color darkCardBg = Color(0xFF353551);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkBorder = Color(0xFF4A4A6A);

  // Legacy fallback (currently used initially, needs refactoring to Theme.of)
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color cardBg = lightCardBg;
  static const Color secondary = Color(0xFFF0EFFF); 
}

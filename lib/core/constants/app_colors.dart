import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Private constructor
  AppColors._();

  // Primary Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);

  // Accent Colors
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Evolution Stage Colors
  static const Color seedColor = Color(0xFF8D6E63);
  static const Color sproutColor = Color(0xFF9CCC65);
  static const Color saplingColor = Color(0xFF66BB6A);
  static const Color treeColor = Color(0xFF43A047);
  static const Color ancientTreeColor = Color(0xFF2E7D32);

  // Activity Colors
  static const Color exerciseColor = Color(0xFFFF5722);
  static const Color meditationColor = Color(0xFF9C27B0);
  static const Color hydrationColor = Color(0xFF2196F3);
  static const Color sleepColor = Color(0xFF3F51B5);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentAmber, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.3);
}

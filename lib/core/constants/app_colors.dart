// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors - Enhanced with modern shades and better contrast
  static const Color primaryGreen = Color(0xFF4CAF50); // Material Green 500
  static const Color primaryDark =
      Color(0xFF2E7D32); // Material Green 800 - darker for better contrast
  static const Color primaryLight =
      Color(0xFF81C784); // Material Green 300 - lighter shade
  static const Color primaryLighter = Color(0xFFC8E6C9); // Material Green 100
  static const Color primaryLightest = Color(0xFFE8F5E9); // Material Green 50

  // Primary colors for dark theme
  static const Color primaryGreenDark =
      Color(0xFF66BB6A); // Lighter green for dark mode
  static const Color primaryDarkDark =
      Color(0xFF388E3C); // Adjusted for dark backgrounds

  // Accent colors - Vibrant and modern
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentBlueLight = Color(0xFF64B5F6);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeLight = Color(0xFFFFB74D);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentPurpleLight = Color(0xFFBA68C8);
  static const Color accentTeal = Color(0xFF009688);
  static const Color accentPink = Color(0xFFE91E63);

  // Text colors - Enhanced contrast for accessibility
  static const Color textPrimary =
      Color(0xFF1A1A1A); // High contrast on light backgrounds
  static const Color textSecondary =
      Color(0xFF424242); // Better contrast than #616161
  static const Color textTertiary = Color(0xFF757575); // Improved visibility
  static const Color textOnPrimary = Colors.white;
  static const Color textOnGreen = Colors.white;
  static const Color textMuted = Color(0xFF757575);

  // Text colors for dark theme
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark =
      Color(0xFFB0B0B0); // Better contrast on dark
  static const Color textTertiaryDark = Color(0xFF9E9E9E);

  // Text on colored backgrounds - ensures visibility
  static const Color textOnGradient = Colors.white;
  static const Color textOnLightBackground = Color(0xFF1A1A1A);
  static const Color textOnDarkBackground = Colors.white;

  // Background colors - Modern and clean
  static const Color background = Color(0xFFFAFAFA); // Material Grey 50
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Material Grey 100
  static const Color divider =
      Color(0xFFE0E0E0); // Material Grey 300 - better visibility

  // Dark theme backgrounds
  static const Color backgroundDark =
      Color(0xFF121212); // Material Dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Material Dark surface
  static const Color surfaceVariantDark =
      Color(0xFF2C2C2C); // Material Dark surface variant
  static const Color dividerDark =
      Color(0xFF424242); // Material Grey 800 - visible on dark

  // Status colors - Enhanced
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Gradients - Premium gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
  );

  // Card gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFAFAFA)],
  );

  // Glass morphism effect
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}

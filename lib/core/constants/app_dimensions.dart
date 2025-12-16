// lib/core/constants/app_dimensions.dart
import 'package:flutter/material.dart';

/// 8px grid system for mathematical precision in layout
class AppDimensions {
  AppDimensions._();

  // Base unit (8px)
  static const double baseUnit = 8.0;

  // Spacing scale (multiples of 8px)
  static const double spacingXS = baseUnit; // 8px
  static const double spacingSM = baseUnit * 2; // 16px
  static const double spacingMD = baseUnit * 3; // 24px
  static const double spacingLG = baseUnit * 4; // 32px
  static const double spacingXL = baseUnit * 6; // 48px
  static const double spacingXXL = baseUnit * 8; // 64px

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingSM = EdgeInsets.all(spacingSM);
  static const EdgeInsets paddingMD = EdgeInsets.all(spacingMD);
  static const EdgeInsets paddingLG = EdgeInsets.all(spacingLG);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS =
      EdgeInsets.symmetric(horizontal: spacingXS);
  static const EdgeInsets paddingHorizontalSM =
      EdgeInsets.symmetric(horizontal: spacingSM);
  static const EdgeInsets paddingHorizontalMD =
      EdgeInsets.symmetric(horizontal: spacingMD);
  static const EdgeInsets paddingHorizontalLG =
      EdgeInsets.symmetric(horizontal: spacingLG);
  static const EdgeInsets paddingHorizontalXL =
      EdgeInsets.symmetric(horizontal: spacingXL);

  // Vertical padding
  static const EdgeInsets paddingVerticalXS =
      EdgeInsets.symmetric(vertical: spacingXS);
  static const EdgeInsets paddingVerticalSM =
      EdgeInsets.symmetric(vertical: spacingSM);
  static const EdgeInsets paddingVerticalMD =
      EdgeInsets.symmetric(vertical: spacingMD);
  static const EdgeInsets paddingVerticalLG =
      EdgeInsets.symmetric(vertical: spacingLG);
  static const EdgeInsets paddingVerticalXL =
      EdgeInsets.symmetric(vertical: spacingXL);

  // Border radius
  static const double radiusXS = baseUnit * 0.5; // 4px
  static const double radiusSM = baseUnit; // 8px
  static const double radiusMD = baseUnit * 2; // 16px
  static const double radiusLG = baseUnit * 3; // 24px
  static const double radiusXL = baseUnit * 4; // 32px
  static const double radiusRound = 9999.0; // Fully rounded

  // Icon sizes
  static const double iconXS = baseUnit * 2; // 16px
  static const double iconSM = baseUnit * 3; // 24px
  static const double iconMD = baseUnit * 4; // 32px
  static const double iconLG = baseUnit * 5; // 40px
  static const double iconXL = baseUnit * 6; // 48px

  // Button heights
  static const double buttonHeightSM = baseUnit * 5; // 40px
  static const double buttonHeightMD = baseUnit * 6; // 48px
  static const double buttonHeightLG = baseUnit * 7; // 56px

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;
  static const double cardPadding = spacingMD;

  // App bar
  static const double appBarHeight = baseUnit * 7; // 56px
  static const double appBarElevation = 0.0;

  // Bottom navigation
  static const double bottomNavHeight = baseUnit * 7; // 56px

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(spacingMD);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: spacingMD);
  static const EdgeInsets screenPaddingVertical =
      EdgeInsets.symmetric(vertical: spacingMD);
}

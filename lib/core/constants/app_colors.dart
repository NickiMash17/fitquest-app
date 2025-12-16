// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/utils/color_utils.dart';

/// Premium, sophisticated color palette for production-grade wellness app
class AppColors {
  AppColors._();

  // === SOPHISTICATED GREEN PALETTE ===
  // Not bright/toy colors - deep, rich, premium greens

  static const MaterialColor primaryGreen = MaterialColor(
    0xFF1E5631, // Deeper, more sophisticated forest green
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF1E5631), // Base - Premium forest green
      600: Color(0xFF1B4D2C),
      700: Color(0xFF184327),
      800: Color(0xFF143921),
      900: Color(0xFF0F2A17),
    },
  );

  // Accent green - for highlights (not lime, sophisticated sage)
  static const accentGreen = Color(0xFF7CB342); // Muted, professional

  // Surface colors with proper elevation
  static const surface0 = Color(0xFFFFFFFF);
  static const surface1 = Color(0xFFF5F7F4);
  static const surface2 = Color(0xFFEBEFE8);
  static const surface3 = Color(0xFFE1E7DC);

  // Premium gold for XP/achievements - refined, not tacky
  static const premiumGold = Color(0xFFD4AF37); // True gold
  static const premiumGoldLight = Color(0xFFFFE082);

  // Premium gold gradient
  static const premiumGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFFFD700),
      Color(0xFFD4AF37),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Pillar accents - MUTED, sophisticated versions
  static const exerciseAccent = Color(0xFFD84315); // Deep burnt orange
  static const meditationAccent = Color(0xFF6A1B9A); // Deep royal purple
  static const hydrationAccent = Color(0xFF0277BD); // Deep ocean blue
  static const sleepAccent = Color(0xFF283593); // Deep navy indigo

  // ========== LIGHT THEME COLORS (from HSL spec) ==========

  // Core Colors
  static Color get background => ColorUtils.hslToColor(80, 25, 97); // #F6F7F2
  static Color get foreground => ColorUtils.hslToColor(150, 30, 15); // #1B3026
  static Color get card => ColorUtils.hslToColor(80, 30, 95); // #F2F4EC
  static Color get cardForeground =>
      ColorUtils.hslToColor(150, 30, 15); // #1B3026

  // Primary - Forest Green
  static Color get primary => ColorUtils.hslToColor(142, 55, 35); // #288347
  static Color get primaryForeground =>
      ColorUtils.hslToColor(80, 25, 98); // #FAFBF7
  static Color get primaryDark => ColorUtils.hslToColor(142, 55, 25); // #1D5C33
  static Color get primaryLight =>
      ColorUtils.hslToColor(142, 55, 45); // #34A85A
  static Color get primaryLightest =>
      ColorUtils.hslToColor(142, 40, 75); // Very light green

  // Secondary - Leaf Green
  static Color get secondary => ColorUtils.hslToColor(120, 35, 85); // #CCE5CC
  static Color get secondaryForeground =>
      ColorUtils.hslToColor(142, 55, 25); // #1D5C33

  // Muted - Sage
  static Color get muted => ColorUtils.hslToColor(100, 20, 90); // #E4E8DE
  static Color get mutedForeground =>
      ColorUtils.hslToColor(130, 15, 45); // #617A66

  // Accent - Lime
  static Color get accent => ColorUtils.hslToColor(95, 60, 50); // #8BC73F
  static Color get accentForeground =>
      ColorUtils.hslToColor(150, 30, 15); // #1B3026

  // XP/Rewards - Golden
  static Color get xp => ColorUtils.hslToColor(45, 95, 55); // #F5C518
  static Color get xpForeground => ColorUtils.hslToColor(40, 80, 20); // #5C4200
  static Color get xpGold => xp; // Alias for compatibility
  static Color get xpGoldLight =>
      ColorUtils.hslToColor(45, 90, 65); // Lighter gold
  static Color get xpGoldDark => ColorUtils.hslToColor(40, 80, 20); // #5C4200

  // Achievement Tiers
  static Color get bronze => ColorUtils.hslToColor(30, 60, 50); // #CC8533
  static Color get silver => ColorUtils.hslToColor(220, 10, 70); // #ADB3B8
  static Color get gold => ColorUtils.hslToColor(45, 90, 55); // #F2C11F

  // Tree Colors
  static Color get treeTrunk => ColorUtils.hslToColor(30, 40, 30); // #6B4D2E
  static Color get treeLeaves => ColorUtils.hslToColor(142, 60, 40); // #29A34D
  static Color get treeLeavesLight =>
      ColorUtils.hslToColor(120, 50, 55); // #5CC75C

  // Borders & Misc
  static Color get border => ColorUtils.hslToColor(120, 20, 85); // #D3DDD3
  static Color get destructive => ColorUtils.hslToColor(0, 84, 60); // #E84747

  // ========== DARK THEME COLORS (from HSL spec) ==========

  static Color get backgroundDark =>
      ColorUtils.hslToColor(150, 25, 8); // #0F1A14
  static Color get foregroundDark =>
      ColorUtils.hslToColor(80, 25, 95); // #F2F4EF
  static Color get cardDark => ColorUtils.hslToColor(150, 20, 12); // #172620
  static Color get primaryDarkTheme =>
      ColorUtils.hslToColor(142, 55, 45); // #34A85A
  static Color get mutedDark => ColorUtils.hslToColor(140, 20, 18); // #233D2E
  static Color get mutedForegroundDark =>
      ColorUtils.hslToColor(120, 15, 60); // #7FA389

  // Legacy compatibility aliases
  // Note: primary getter is defined below in LIGHT THEME COLORS section
  static Color get primaryGreenDark => primaryDarkTheme;

  // Legacy compatibility - Text colors
  static Color get textPrimary => foreground;
  static Color get textSecondary => mutedForeground;
  static Color get textTertiary => mutedForeground;
  static Color get textOnPrimary => primaryForeground;
  static Color get textOnGreen => primaryForeground;
  static Color get textMuted => mutedForeground;
  static Color get textPrimaryDark => foregroundDark;
  static Color get textSecondaryDark => mutedForegroundDark;
  static Color get textTertiaryDark => mutedForegroundDark;
  static Color get textOnGradient => Colors.white;
  static Color get textOnLightBackground => foreground;
  static Color get textOnDarkBackground => foregroundDark;

  // Legacy compatibility - Background colors
  static Color get surface => Colors.white;
  static Color get surfaceVariant => muted;
  static Color get divider => border;
  static Color get surfaceDark => cardDark;
  static Color get surfaceVariantDark => mutedDark;
  static Color get dividerDark => mutedForegroundDark;

  // Status colors
  static Color get success => ColorUtils.hslToColor(142, 55, 45);
  static Color get successLight => ColorUtils.hslToColor(142, 55, 55);
  static Color get warning => ColorUtils.hslToColor(45, 95, 55);
  static Color get warningLight => ColorUtils.hslToColor(45, 90, 65);
  static Color get error => destructive;
  static Color get errorLight => ColorUtils.hslToColor(0, 84, 70);
  static Color get info => ColorUtils.hslToColor(200, 80, 50);
  static Color get infoLight => ColorUtils.hslToColor(200, 80, 65);

  // Accent colors (for compatibility)
  static Color get accentBlue => ColorUtils.hslToColor(200, 80, 50);
  static Color get accentBlueLight => ColorUtils.hslToColor(200, 80, 65);
  static Color get accentOrange => ColorUtils.hslToColor(30, 90, 55);
  static Color get accentOrangeLight => ColorUtils.hslToColor(30, 90, 65);
  static Color get accentPurple => ColorUtils.hslToColor(280, 60, 50);
  static Color get accentPurpleLight => ColorUtils.hslToColor(280, 60, 65);
  static Color get accentTeal => ColorUtils.hslToColor(180, 60, 50);
  static Color get accentPink => ColorUtils.hslToColor(340, 70, 55);

  // Shadow colors
  static Color get shadowLight => const Color(0x1A000000);
  static Color get shadowMedium => const Color(0x33000000);
  static Color get shadowDark => const Color(0x4D000000);

  // ========== GRADIENTS (from spec) ==========

  // Nature gradient (primary)
  static LinearGradient get gradientNature => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ColorUtils.hslToColor(142, 55, 35), // primary
          ColorUtils.hslToColor(120, 50, 45), // lighter green
        ],
      );

  // Sky gradient
  static LinearGradient get gradientSky => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorUtils.hslToColor(200, 80, 85),
          ColorUtils.hslToColor(195, 70, 95),
        ],
      );

  // Ground gradient
  static LinearGradient get gradientGround => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorUtils.hslToColor(95, 35, 75),
          ColorUtils.hslToColor(80, 30, 85),
        ],
      );

  // XP gradient
  static LinearGradient get gradientXp => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          ColorUtils.hslToColor(45, 95, 55), // xp
          ColorUtils.hslToColor(38, 90, 60), // slightly different gold
        ],
      );

  // Legacy compatibility gradients
  static LinearGradient get primaryGradient => gradientNature;
  static LinearGradient get primaryGradientLight => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryLight, primary],
      );
  static LinearGradient get xpGradient => gradientXp;
  static LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, ColorUtils.hslToColor(95, 60, 45)],
      );
  static LinearGradient get blueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentBlue, accentBlueLight],
      );
  static LinearGradient get purpleGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentPurple, accentPurpleLight],
      );
  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, background],
      );

  // Glass morphism effect
  static Color get glassBackground => card.withValues(alpha: 0.8);
  static Color get glassBorder => border.withValues(alpha: 0.5);

  // ========== SHADOWS (from spec) ==========

  // Soft shadow
  static BoxShadow get softShadow => BoxShadow(
        color: primary.withValues(alpha: 0.15),
        blurRadius: 20,
        offset: const Offset(0, 4),
      );

  // XP Glow
  static BoxShadow get xpGlow => BoxShadow(
        color: xp.withValues(alpha: 0.4),
        blurRadius: 20,
      );

  // Nature Glow
  static BoxShadow get natureGlow => BoxShadow(
        color: accent.withValues(alpha: 0.3),
        blurRadius: 30,
      );
}

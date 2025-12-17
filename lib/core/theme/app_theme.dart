import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Cache font styles to avoid repeated GoogleFonts calls (performance optimization)
  static final TextStyle _fredokaDisplayLarge = GoogleFonts.fredoka(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.2,
  );
  static final TextStyle _fredokaDisplayMedium = GoogleFonts.fredoka(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );
  static final TextStyle _fredokaDisplaySmall = GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );
  static final TextStyle _fredokaHeadlineLarge = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  static final TextStyle _fredokaHeadlineMedium = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );
  static final TextStyle _fredokaHeadlineSmall = GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );
  static final TextStyle _fredokaTitleLarge = GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );
  static final TextStyle _nunitoTitleMedium = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  static final TextStyle _nunitoTitleSmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  static final TextStyle _nunitoBodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.6,
  );
  static final TextStyle _nunitoBodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
    height: 1.6,
  );
  static final TextStyle _nunitoBodySmall = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.4,
    height: 1.5,
  );
  static final TextStyle _nunitoLabelLarge = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  static final TextStyle _nunitoLabelMedium = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );
  static final TextStyle _nunitoLabelSmall = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
    height: 1.4,
  );
  static final TextStyle _fredokaAppBar = GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      error: AppColors.error,
      errorContainer: AppColors.errorLight,
      onPrimary: AppColors.primaryForeground,
      onSecondary: AppColors.secondaryForeground,
      onSurface: AppColors.foreground,
      onError: Colors.white,
      outline: AppColors.border,
      shadow: AppColors.shadowLight,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: _fredokaAppBar,
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),
    textTheme: TextTheme(
      displayLarge: _fredokaDisplayLarge,
      displayMedium: _fredokaDisplayMedium,
      displaySmall: _fredokaDisplaySmall,
      headlineLarge: _fredokaHeadlineLarge,
      headlineMedium: _fredokaHeadlineMedium,
      headlineSmall: _fredokaHeadlineSmall,
      titleLarge: _fredokaTitleLarge,
      titleMedium: _nunitoTitleMedium,
      titleSmall: _nunitoTitleSmall,
      bodyLarge: _nunitoBodyLarge,
      bodyMedium: _nunitoBodyMedium,
      bodySmall: _nunitoBodySmall,
      labelLarge: _nunitoLabelLarge,
      labelMedium: _nunitoLabelMedium,
      labelSmall: _nunitoLabelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: _fredokaTitleLarge.copyWith(fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: _nunitoLabelLarge.copyWith(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.divider, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.divider, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: _nunitoLabelLarge.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      hintStyle: _nunitoLabelLarge.copyWith(
        color: AppColors.textTertiary,
      ),
      helperStyle: _nunitoLabelMedium.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLG,
        side: BorderSide.none,
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: const Color(0xFF616161),
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: const IconThemeData(size: 24),
      selectedLabelStyle: _nunitoLabelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: _nunitoLabelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDarkTheme,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      surface: AppColors.surfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      error: AppColors.error,
      errorContainer: AppColors.errorLight,
      onPrimary: AppColors.primaryForeground,
      onSecondary: AppColors.secondaryForeground,
      onSurface: AppColors.foregroundDark,
      onError: Colors.white,
      outline: AppColors.border,
      shadow: Colors.black.withValues(alpha: 0.3),
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: _fredokaAppBar,
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),
    textTheme: TextTheme(
      displayLarge: _fredokaDisplayLarge.copyWith(color: Colors.white),
      displayMedium: _fredokaDisplayMedium.copyWith(color: Colors.white),
      displaySmall: _fredokaDisplaySmall.copyWith(color: Colors.white),
      headlineLarge: _fredokaHeadlineLarge.copyWith(color: Colors.white),
      headlineMedium: _fredokaHeadlineMedium.copyWith(color: Colors.white),
      headlineSmall: _fredokaHeadlineSmall.copyWith(color: Colors.white),
      titleLarge: _fredokaTitleLarge.copyWith(color: Colors.white),
      titleMedium: _nunitoTitleMedium.copyWith(color: Colors.white),
      titleSmall: _nunitoTitleSmall.copyWith(color: Colors.white),
      bodyLarge: _nunitoBodyLarge.copyWith(color: Colors.white),
      bodyMedium:
          _nunitoBodyMedium.copyWith(color: AppColors.textSecondaryDark),
      bodySmall: _nunitoBodySmall.copyWith(color: AppColors.textTertiaryDark),
      labelLarge: _nunitoLabelLarge.copyWith(color: Colors.white),
      labelMedium:
          _nunitoLabelMedium.copyWith(color: AppColors.textSecondaryDark),
      labelSmall: _nunitoLabelSmall.copyWith(color: AppColors.textTertiaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        minimumSize: const Size(120, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allMD,
        ),
        textStyle: _nunitoTitleMedium.copyWith(letterSpacing: 0.5),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith<double>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.disabled)) return 0;
            return 0;
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(64, 40),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allSM,
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: Color(0xFF424242), width: 1.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: Color(0xFF424242), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allMD,
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      ),
      hintStyle: GoogleFonts.nunito(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      helperStyle: GoogleFonts.nunito(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLG,
        side: BorderSide.none,
      ),
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: const IconThemeData(size: 24),
      selectedLabelStyle: _nunitoLabelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: _nunitoLabelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

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
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.25,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
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
      focusedBorder: OutlineInputBorder(
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
      labelStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.nunito(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
      helperStyle: GoogleFonts.nunito(
        fontSize: 12,
        color: AppColors.textTertiary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
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
      selectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
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
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.fredoka(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        letterSpacing: 0.15,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryDark,
        letterSpacing: 0.25,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiaryDark,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiaryDark,
        letterSpacing: 0.5,
        height: 1.4,
      ),
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
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
      selectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}

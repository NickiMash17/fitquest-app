import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_typography.dart';

class AppTheme {
  AppTheme._();

  // Prefer AppTypography getters for consistent typographic scale
  static final TextStyle _fredokaAppBar = AppTypography.headlineSmall.copyWith(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
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
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.headlineSmall.copyWith(fontSize: 18),
      titleMedium: AppTypography.bodyLarge,
      titleSmall: AppTypography.bodyMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.bodySmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLG),
        textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: AppTypography.labelLarge.copyWith(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface.withValues(alpha: 0.96),
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
      labelStyle: AppTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      helperStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLG,
        side: BorderSide.none,
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: const Color(0xFF616161),
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: const IconThemeData(size: 24),
      selectedLabelStyle: AppTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryLight,
      labelTextStyle: MaterialStateProperty.all(
        AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        return IconThemeData(color: AppColors.primary);
      }),
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
      displayLarge: AppTypography.displayLarge.copyWith(color: Colors.white),
      displayMedium: AppTypography.displayMedium.copyWith(color: Colors.white),
      displaySmall: AppTypography.displaySmall.copyWith(color: Colors.white),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: Colors.white),
      headlineMedium:
          AppTypography.headlineMedium.copyWith(color: Colors.white),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: Colors.white),
      titleLarge: AppTypography.headlineSmall.copyWith(color: Colors.white),
      titleMedium: AppTypography.bodyLarge.copyWith(color: Colors.white),
      titleSmall: AppTypography.bodyMedium.copyWith(color: Colors.white),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white),
      bodyMedium:
          AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
      bodySmall:
          AppTypography.bodySmall.copyWith(color: AppColors.textTertiaryDark),
      labelLarge: AppTypography.labelLarge.copyWith(color: Colors.white),
      labelMedium: AppTypography.labelMedium
          .copyWith(color: AppColors.textSecondaryDark),
      labelSmall:
          AppTypography.bodySmall.copyWith(color: AppColors.textTertiaryDark),
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
        textStyle: AppTypography.bodyLarge.copyWith(letterSpacing: 0.5),
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
        textStyle: AppTypography.labelLarge.copyWith(
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
      labelStyle: AppTypography.labelLarge.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      ),
      hintStyle: AppTypography.labelLarge.copyWith(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      helperStyle: AppTypography.labelMedium.copyWith(
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
      selectedLabelStyle: AppTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}

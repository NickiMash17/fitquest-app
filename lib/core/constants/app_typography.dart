// lib/core/constants/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Professional type scale with proper hierarchy - Production Grade
class AppTypography {
  AppTypography._();

  // Professional type scale with proper hierarchy

  static const String displayFont = 'Fredoka'; // Headings
  static const String bodyFont =
      'Inter'; // Changed to Inter for body (more professional than Nunito)

  // Display styles - for hero sections
  static TextStyle get displayLarge => GoogleFonts.fredoka(
        fontSize: 57,
        height: 1.12,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayMedium => GoogleFonts.fredoka(
        fontSize: 45,
        height: 1.16,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displaySmall => GoogleFonts.fredoka(
        fontSize: 36,
        height: 1.22,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
      );

  // Headline styles - for section headers
  static TextStyle get headlineLarge => GoogleFonts.fredoka(
        fontSize: 32,
        height: 1.25,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => GoogleFonts.fredoka(
        fontSize: 28,
        height: 1.29,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get headlineSmall => GoogleFonts.fredoka(
        fontSize: 24,
        height: 1.33,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      );

  // Body styles - for content
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        letterSpacing: 0.15,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        height: 1.33,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w400,
      );

  // Label styles - for buttons, badges
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        height: 1.43,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        height: 1.33,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      );

  // Premium styles - for special elements
  static TextStyle get xpNumber => GoogleFonts.fredoka(
        fontSize: 32,
        height: 1.0,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        shadows: [
          Shadow(
            blurRadius: 12,
            color: AppColors.premiumGold.withOpacity(0.6),
            offset: const Offset(0, 2),
          ),
        ],
      );

  static TextStyle get statNumber => GoogleFonts.fredoka(
        fontSize: 28,
        height: 1.0,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
      );
}

// lib/core/constants/app_shadows.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Consistent shadow system for the app
class AppShadows {
  AppShadows._();

  // Light shadows for elevated surfaces
  static List<BoxShadow> get light => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  // Medium shadows for cards
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // Large shadows for modals and dialogs
  static List<BoxShadow> get large => [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  // Soft shadow for subtle elevation
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  // Colored shadow for primary elements
  static List<BoxShadow> primaryShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];
}

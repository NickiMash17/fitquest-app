import 'package:flutter/material.dart';
import 'package:fitquest/shared/widgets/enhanced_snackbar.dart';

/// Toast notification service - uses EnhancedSnackBar for better UX
class ToastService {
  /// Show success toast
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    EnhancedSnackBar.showSuccess(context, message, duration: duration);
  }

  /// Show error toast
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    EnhancedSnackBar.showError(context, message, duration: duration);
  }

  /// Show info toast
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    EnhancedSnackBar.showInfo(context, message, duration: duration);
  }

  /// Show warning toast
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    EnhancedSnackBar.showWarning(context, message, duration: duration);
  }
}

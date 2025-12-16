// lib/core/services/haptic_service.dart
import 'package:flutter/services.dart';

/// Production-grade haptic feedback service
class HapticService {
  HapticService._();

  /// Light haptic feedback for subtle interactions
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard interactions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important interactions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success haptic feedback pattern
  static Future<void> success() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.mediumImpact();
  }

  /// Error haptic feedback pattern
  static Future<void> error() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }
}

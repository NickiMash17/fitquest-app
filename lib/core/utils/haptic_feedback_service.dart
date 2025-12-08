import 'package:flutter/services.dart';

/// Service for haptic feedback using Flutter's built-in HapticFeedback
class HapticFeedbackService {
  /// Light impact feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact feedback
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection feedback
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Success feedback (medium impact)
  static void success() {
    mediumImpact();
  }

  /// Error feedback (heavy impact)
  static void error() {
    heavyImpact();
  }

  /// Warning feedback (light impact)
  static void warning() {
    lightImpact();
  }
}


import 'package:flutter/material.dart';

/// Utility functions for managing focus in the app
/// Helps with keyboard navigation and accessibility
class FocusUtils {
  /// Move focus to the next focusable widget
  static void moveToNextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to the previous focusable widget
  static void moveToPreviousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus the current focus node
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Request focus on a specific focus node
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Scroll to ensure a widget is visible when focused
  /// Useful for form fields that might be hidden by the keyboard
  static void ensureVisible(BuildContext context, {Duration? duration}) {
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      Scrollable.ensureVisible(
        context,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}


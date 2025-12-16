// lib/core/constants/app_breakpoints.dart
import 'package:flutter/material.dart';

/// Responsive breakpoints for adaptive layouts
class AppBreakpoints {
  AppBreakpoints._();

  // Screen width breakpoints
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;
  static const double largeDesktop = 1800.0;

  // Helper methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  // Get responsive value
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop;
    }
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}

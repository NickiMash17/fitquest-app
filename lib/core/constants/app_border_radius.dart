// lib/core/constants/app_border_radius.dart
import 'package:flutter/material.dart';

/// Consistent border radius system
class AppBorderRadius {
  AppBorderRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 999.0; // Fully rounded

  // Common border radius
  static const BorderRadius allXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius allSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius allXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius allRound = BorderRadius.all(Radius.circular(round));

  // Top border radius
  static const BorderRadius topMD =
      BorderRadius.vertical(top: Radius.circular(md));
  static const BorderRadius topLG =
      BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius topXL =
      BorderRadius.vertical(top: Radius.circular(xl));

  // Bottom border radius
  static const BorderRadius bottomMD =
      BorderRadius.vertical(bottom: Radius.circular(md));
  static const BorderRadius bottomLG =
      BorderRadius.vertical(bottom: Radius.circular(lg));
}

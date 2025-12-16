// lib/core/constants/app_durations.dart
import 'package:flutter/material.dart';

/// Animation durations for consistent, premium feel
class AppDurations {
  AppDurations._();

  // Quick animations (micro-interactions)
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration quickSlow = Duration(milliseconds: 200);

  // Moderate animations (standard transitions)
  static const Duration moderate = Duration(milliseconds: 300);
  static const Duration moderateSlow = Duration(milliseconds: 400);

  // Slow animations (complex transitions)
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowSlow = Duration(milliseconds: 600);

  // Very slow animations (elaborate effects)
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration verySlowSlow = Duration(milliseconds: 1000);

  // Special animations
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration modalTransition = Duration(milliseconds: 400);
  static const Duration treeGrowth = Duration(milliseconds: 1200);
  static const Duration celebration = Duration(milliseconds: 2000);

  // Curves for premium feel
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve quickCurve = Curves.easeOut;
  static const Curve slowCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOut;
}

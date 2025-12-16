// lib/core/constants/app_shadows.dart
import 'package:flutter/material.dart';

/// Layered shadows for realistic depth - Production Grade
class AppShadows {
  AppShadows._();

  // Layered shadows for realistic depth

  static const elevation1 = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 1,
      offset: Offset(0, 0.5),
    ),
  ];

  static const elevation2 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const elevation3 = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const premiumGlow = [
    BoxShadow(
      color: Color(0x40D4AF37),
      blurRadius: 32,
      offset: Offset(0, 0),
    ),
    BoxShadow(
      color: Color(0x20D4AF37),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Inner shadows (requires custom implementation)
  static const innerShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  // Legacy compatibility
  static List<BoxShadow> get light => elevation1;
  static List<BoxShadow> get medium => elevation2;
  static List<BoxShadow> get large => elevation3;
  static List<BoxShadow> get soft => elevation2;

  static List<BoxShadow> primaryShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

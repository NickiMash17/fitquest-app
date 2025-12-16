// lib/core/constants/app_gradients.dart
import 'package:flutter/material.dart';

/// Sophisticated gradients - subtle, multi-stop, professional
class AppGradients {
  AppGradients._();

  // Sophisticated gradients - subtle, multi-stop, professional

  static const premiumGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E5631),
      Color(0xFF2D7A4A),
      Color(0xFF1E5631),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const glassEffect = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  static const premiumGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFFFD700),
      Color(0xFFD4AF37),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Mesh gradients for depth (requires custom implementation)
  static const meshBackground = [
    Color(0xFFF5F7F4),
    Color(0xFFE8F0E3),
    Color(0xFFD9E7D1),
  ];

  // Legacy compatibility
  static const Gradient level1to4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
  );

  static const Gradient level5to9 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
  );

  static const Gradient level10to14 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  static const Gradient level15to19 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
  );

  static const Gradient level20plus = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const Gradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F5F5),
    ],
  );

  static const Gradient premiumCardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C2C2C),
      Color(0xFF1E1E1E),
    ],
  );

  static Gradient glassmorphicLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.25),
      Colors.white.withOpacity(0.1),
    ],
  );

  static Gradient glassmorphicDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  );
}

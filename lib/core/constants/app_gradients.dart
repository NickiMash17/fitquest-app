// lib/core/constants/app_gradients.dart
import 'package:flutter/material.dart';

/// Premium gradient system for the app
class AppGradients {
  AppGradients._();

  // Level-based avatar gradients
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

  // Premium card gradients
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

  // Glassmorphic gradients
  static Gradient glassmorphicLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.25),
      Colors.white.withValues(alpha: 0.1),
    ],
  );

  static Gradient glassmorphicDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.1),
      Colors.white.withValues(alpha: 0.05),
    ],
  );

  // Accent gradients
  static const Gradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  static const Gradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const Gradient forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF134E5E), Color(0xFF71B280)],
  );

  static const Gradient aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
  );
}


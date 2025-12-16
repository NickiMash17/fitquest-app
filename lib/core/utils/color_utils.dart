// lib/core/utils/color_utils.dart
import 'package:flutter/material.dart';

/// Utility class for color conversions
class ColorUtils {
  ColorUtils._();

  /// Convert HSL to Flutter Color
  /// HSL values: h (0-360), s (0-100), l (0-100)
  static Color hslToColor(double h, double s, double l) {
    // Normalize HSL values
    h = h / 360.0;
    s = s / 100.0;
    l = l / 100.0;

    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double hue2rgb(double p, double q, double t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      }

      final double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final double p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      1.0,
    );
  }
}


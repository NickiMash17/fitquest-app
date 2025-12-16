// lib/shared/widgets/gradient_background.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Gradient background widget for pages
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: begin,
              end: end,
              colors: colors ??
                  [
                    isDark ? AppColors.backgroundDark : AppColors.background,
                    isDark ? AppColors.surfaceDark : AppColors.card,
                  ],
            ),
      ),
      child: child,
    );
  }
}

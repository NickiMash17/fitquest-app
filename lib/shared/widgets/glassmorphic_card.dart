// lib/shared/widgets/glassmorphic_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Glassmorphic card widget for modern aesthetic
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderColor,
    this.borderWidth = 1.0,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLG,
        border: Border.all(
          color: borderColor ??
              Colors.white.withValues(alpha: isDark ? 0.1 : 0.3),
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.allLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.1 : opacity),
                      Colors.white.withValues(alpha: isDark ? 0.05 : opacity * 0.5),
                    ],
                  ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppBorderRadius.allLG,
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20.0),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


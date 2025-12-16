// lib/shared/widgets/glassmorphic_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// GlassCard component matching spec:
/// - backgroundColor: card.withOpacity(0.8)
/// - backdropFilter: blur(8px)
/// - border: 1px solid border.withOpacity(0.5)
/// - boxShadow: softShadow
/// - borderRadius: 16px
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLG, // 16px
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [AppColors.softShadow],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.allLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // blur(8px)
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.8), // card.withOpacity(0.8)
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


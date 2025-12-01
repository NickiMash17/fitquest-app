// lib/shared/widgets/premium_card.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Premium card widget with modern design
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool showShadow;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.showShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: AppBorderRadius.allLG,
        border: border,
        boxShadow: showShadow ? AppShadows.soft : null,
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
    );

    return card;
  }
}

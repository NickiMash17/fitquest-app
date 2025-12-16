// lib/core/widgets/premium_glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/constants/app_dimensions.dart';
import 'package:fitquest/core/constants/app_durations.dart';
import 'package:fitquest/core/services/haptic_service.dart';

/// Elite Glass Card with premium interactions
class PremiumGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? borderColor;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevated = false,
    this.borderColor,
  });

  @override
  State<PremiumGlassCard> createState() => _PremiumGlassCardState();
}

class _PremiumGlassCardState extends State<PremiumGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.quick,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppDurations.standardCurve,
      ),
    );

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppDurations.standardCurve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = widget.borderColor ??
        (isDark
            ? AppColors.primaryGreen.shade300.withValues(alpha: 0.2)
            : AppColors.primaryGreen.shade200.withValues(alpha: 0.3));

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) {
              _controller.forward();
              HapticService.light();
            }
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () {
              _controller.reverse();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: widget.padding ?? AppDimensions.paddingMD,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          surfaceColor.withValues(alpha: 0.95),
                          surfaceColor.withValues(alpha: 0.85),
                        ]
                      : [
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                        ],
                ),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: [
                  ...AppShadows.elevation2,
                  if (widget.elevated)
                    BoxShadow(
                      color: AppColors.primaryGreen.shade500.withValues(
                        alpha: 0.1 * _elevationAnimation.value,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

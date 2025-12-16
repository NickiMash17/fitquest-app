// lib/shared/widgets/premium_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Premium card widget with modern design
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
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
    this.onDoubleTap,
    this.showShadow = true,
    this.border,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
      HapticFeedbackService.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Enhanced shadows for glassmorphism effect
    final cardBackground = widget.gradient != null
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    surfaceColor.withValues(alpha: 0.95),
                    surfaceColor.withValues(alpha: 0.85),
                  ]
                : [
                    surfaceColor.withValues(alpha: 0.95),
                    surfaceColor.withValues(alpha: 0.85),
                  ],
          );

    final enhancedShadows = widget.showShadow
        ? [
            // Primary shadow with brand color tint
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            // Soft highlight (theme-aware)
            if (!isDark)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            // Base shadow (theme-aware)
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ]
        : null;

    final Widget card = Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? cardBackground,
        borderRadius: AppBorderRadius.allLG,
        border: widget.border ??
            Border.all(
              width: 1.0,
              color: isDark
                  ? AppColors.primaryGreen.shade300.withValues(alpha: 0.2)
                  : AppColors.glassBorder,
            ),
        boxShadow: enhancedShadows,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.allLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTapDown: widget.onTap != null ? _handleTapDown : null,
              onTapUp: widget.onTap != null ? _handleTapUp : null,
              onTapCancel: widget.onTap != null ? _handleTapCancel : null,
              onTap: widget.onTap,
              onDoubleTap: widget.onDoubleTap,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: InkWell(
                  onTap: null, // Handled by GestureDetector
                  borderRadius: AppBorderRadius.allLG,
                  splashColor: widget.gradient != null
                      ? onSurface.withValues(alpha: 0.1)
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.all(20.0),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Add semantics for accessibility when card is tappable
    if (widget.onTap != null || widget.onDoubleTap != null) {
      return Semantics(
        button: true,
        hint: widget.onDoubleTap != null
            ? 'Double tap to view details'
            : 'Double tap to open',
        child: card,
      );
    }

    return card;
  }
}

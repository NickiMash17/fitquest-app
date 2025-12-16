// lib/shared/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Premium glassmorphism card with multi-layer depth and shadows
/// Phase 1: Foundation - Glassmorphism 2.0 with enhanced shadows
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final double? width;
  final double? height;
  final bool enableHaptic;
  final bool enablePressAnimation;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.onDoubleTap,
    this.width,
    this.height,
    this.enableHaptic = true,
    this.enablePressAnimation = true,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enablePressAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
      if (widget.enableHaptic) {
        HapticFeedbackService.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enablePressAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.enablePressAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  List<BoxShadow> get _elevatedShadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 30,
          offset: const Offset(0, 15),
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ];

  List<BoxShadow> get _innerShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 2),
          spreadRadius: -8,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBackground = widget.backgroundColor ??
        (isDark
            ? Theme.of(context).colorScheme.surface
            : AppColors.surface);

    final cardBackground = widget.gradient != null
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              defaultBackground.withValues(alpha: 0.7),
              defaultBackground.withValues(alpha: 0.3),
            ],
          );

    final borderRadius = widget.borderRadius ?? AppBorderRadius.allLG;

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? cardBackground,
        borderRadius: borderRadius,
        border: Border.all(
          width: 1.5,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: _isPressed ? _innerShadow : _elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTapDown: widget.onTap != null ? _handleTapDown : null,
              onTapUp: widget.onTap != null ? _handleTapUp : null,
              onTapCancel: widget.onTap != null ? _handleTapCancel : null,
              onTap: _handleTap,
              onDoubleTap: widget.onDoubleTap,
              child: widget.enablePressAnimation
                  ? AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Padding(
                            padding: widget.padding ??
                                const EdgeInsets.all(20.0),
                            child: widget.child,
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: widget.padding ?? const EdgeInsets.all(20.0),
                      child: widget.child,
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


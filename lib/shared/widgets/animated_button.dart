// lib/shared/widgets/animated_button.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Premium animated button with press effects and haptic feedback
/// Phase 1: Foundation - Button press animations with scale and shadow changes
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final bool enableHaptic;
  final bool enablePressAnimation;
  final Duration animationDuration;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.customShadow,
    this.enableHaptic = true,
    this.enablePressAnimation = true,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
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

  List<BoxShadow> get _elevatedShadow => widget.customShadow ?? [
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && widget.enablePressAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
      if (widget.enableHaptic) {
        HapticFeedbackService.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && widget.enablePressAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && widget.enablePressAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? AppBorderRadius.allMD;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: widget.enablePressAnimation
          ? AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                    decoration: BoxDecoration(
                      color: widget.gradient == null
                          ? (widget.backgroundColor ?? AppColors.primary)
                          : null,
                      gradient: widget.gradient,
                      borderRadius: borderRadius,
                      boxShadow: _isPressed ? _innerShadow : _elevatedShadow,
                    ),
                    child: widget.child,
                  ),
                );
              },
            )
          : Container(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
              decoration: BoxDecoration(
                color: widget.gradient == null
                    ? (widget.backgroundColor ?? AppColors.primary)
                    : null,
                gradient: widget.gradient,
                borderRadius: borderRadius,
                boxShadow: _elevatedShadow,
              ),
              child: widget.child,
            ),
    );
  }
}


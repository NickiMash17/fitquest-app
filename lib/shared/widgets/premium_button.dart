// lib/shared/widgets/premium_button.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_typography.dart';

/// Premium button with advanced animations and effects
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final EdgeInsets? padding;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.padding,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
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
    final gradient = widget.gradient ?? AppColors.primaryGradient;
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;

    final button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: widget.gradient != null ? gradient : null,
                color: widget.gradient == null ? backgroundColor : null,
                borderRadius: AppBorderRadius.allLG,
                boxShadow: [
                  BoxShadow(
                    color: (widget.gradient != null
                            ? AppColors.primaryGreen
                            : backgroundColor)
                        .withValues(alpha: 0.4 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    offset: Offset(0, 8 * _glowAnimation.value),
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: (widget.gradient != null
                            ? AppColors.primaryGreen
                            : backgroundColor)
                        .withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Wrap with Semantics for accessibility
    return Semantics(
      label: widget.label,
      hint: widget.isLoading
          ? 'Loading, please wait'
          : widget.onPressed == null
              ? 'Button disabled'
              : 'Double tap to activate',
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      child: button,
    );
  }
}

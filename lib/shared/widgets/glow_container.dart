// lib/shared/widgets/glow_container.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Container with animated glow effect
class GlowContainer extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;

  GlowContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF288347), // AppColors.primaryGreen equivalent
    this.blurRadius = 20,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
  });

  @override
  State<GlowContainer> createState() => _GlowContainerState();
}

class _GlowContainerState extends State<GlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? AppBorderRadius.allLG,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.6 * _glowAnimation.value),
                blurRadius: widget.blurRadius * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.3),
                blurRadius: widget.blurRadius * 0.5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}


// lib/shared/widgets/gradient_border_card.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'dart:math' as math;

/// Card with animated gradient border
/// Phase 4: Gradient borders for featured cards
class GradientBorderCard extends StatefulWidget {
  final Widget child;
  final Gradient gradient;
  final double borderWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final bool animated;
  final Duration animationDuration;

  const GradientBorderCard({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 2.0,
    this.padding,
    this.margin,
    this.borderRadius,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      )..repeat();

      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? AppBorderRadius.allLG;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: widget.animated
            ? _createAnimatedGradient(
                widget.gradient,
                _animation.value,
              )
            : widget.gradient,
      ),
      padding: EdgeInsets.all(widget.borderWidth),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius,
        ),
        child: widget.child,
      ),
    );
  }
}

LinearGradient _createAnimatedGradient(
  Gradient baseGradient,
  double animationValue,
) {
  if (baseGradient is LinearGradient) {
    final linear = baseGradient;
    // Animate gradient position
    final offset = animationValue * 2 * math.pi;
    return LinearGradient(
      begin: Alignment(
        math.cos(offset),
        math.sin(offset),
      ),
      end: Alignment(
        -math.cos(offset),
        -math.sin(offset),
      ),
      colors: linear.colors,
      stops: linear.stops,
    );
  }
  return baseGradient as LinearGradient;
}

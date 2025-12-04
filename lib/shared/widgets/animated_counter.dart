import 'package:flutter/material.dart';

/// Animated counter widget with smooth number transitions
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? textStyle;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.textStyle,
    this.duration = const Duration(milliseconds: 800),
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}$animatedValue${suffix ?? ''}',
          style: textStyle,
        );
      },
    );
  }
}

/// Animated opacity widget for fade-in effects
class FadeInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Animated scale widget for scale-in effects
class ScaleInWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;

  const ScaleInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutBack,
    this.begin = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Staggered animation for lists
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDuration;
  final Duration itemDuration;

  const StaggeredList({
    super.key,
    required this.children,
    this.staggerDuration = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: itemDuration + (staggerDuration * index),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}



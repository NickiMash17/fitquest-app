// lib/core/widgets/staggered_animation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_durations.dart';

/// Wrapper for staggered entrance animations
class StaggeredAnimationWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const StaggeredAnimationWrapper({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<StaggeredAnimationWrapper> createState() =>
      _StaggeredAnimationWrapperState();
}

class _StaggeredAnimationWrapperState
    extends State<StaggeredAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.moderate,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: AppDurations.standardCurve),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: AppDurations.standardCurve),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: AppDurations.standardCurve),
      ),
    );

    // Start animation with delay
    Future.delayed(
      widget.delay * widget.index,
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


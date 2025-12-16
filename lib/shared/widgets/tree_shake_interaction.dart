// lib/shared/widgets/tree_shake_interaction.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';
import 'dart:math' as math;

/// Interactive tree widget with tap-to-shake effect
/// Phase 3: Tap-to-shake interaction
class TreeShakeInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback? onShake;
  final Duration shakeDuration;
  final double shakeIntensity;

  const TreeShakeInteraction({
    super.key,
    required this.child,
    this.onShake,
    this.shakeDuration = const Duration(milliseconds: 500),
    this.shakeIntensity = 10.0,
  });

  @override
  State<TreeShakeInteraction> createState() => _TreeShakeInteractionState();
}

class _TreeShakeInteractionState extends State<TreeShakeInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: widget.shakeDuration,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedbackService.mediumImpact();
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
    widget.onShake?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shake = math.sin(_shakeAnimation.value * math.pi * 4) *
              widget.shakeIntensity *
              (1 - _shakeAnimation.value);
          return Transform.translate(
            offset: Offset(shake * (1 - _shakeAnimation.value), 0),
            child: widget.child,
          );
        },
      ),
    );
  }
}

// lib/shared/widgets/celebration_animation.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'package:fitquest/core/constants/app_colors.dart';

/// Celebration animation widget with confetti and particles
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color? confettiColor;
  final Duration duration;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.isActive = false,
    this.confettiColor,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.isActive) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _confettiController.play();
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.confettiColor ?? AppColors.primaryGreen;

    return Stack(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.02,
                numberOfParticles: 50,
                gravity: 0.3,
                colors: [
                  color,
                  AppColors.accentOrange,
                  AppColors.accentBlue,
                  AppColors.accentPurple,
                  Colors.white,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Success checkmark animation
class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;

  const SuccessCheckmark({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primaryGreen;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CheckmarkPainter(
            color: Colors.white,
            progress: _checkAnimation.value,
          ),
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double progress;

  _CheckmarkPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (progress > 0) {
      // Draw first line of checkmark
      final firstLineEnd = progress < 0.5
          ? progress * 2
          : 1.0;
      canvas.drawLine(
        Offset(size.width * 0.25, size.height * 0.5),
        Offset(
          size.width * 0.25 + (size.width * 0.2 * firstLineEnd),
          size.height * 0.5 + (size.height * 0.2 * firstLineEnd),
        ),
        paint,
      );

      // Draw second line of checkmark
      if (progress > 0.5) {
        final secondLineProgress = (progress - 0.5) * 2;
        canvas.drawLine(
          Offset(size.width * 0.45, size.height * 0.7),
          Offset(
            size.width * 0.45 + (size.width * 0.3 * secondLineProgress),
            size.height * 0.7 - (size.height * 0.4 * secondLineProgress),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


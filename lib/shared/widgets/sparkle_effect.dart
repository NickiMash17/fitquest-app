import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

/// Sparkle effect widget for XP gains and achievements
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final bool active;
  final Color sparkleColor;
  final int sparkleCount;

  const SparkleEffect({
    super.key,
    required this.child,
    this.active = false,
    this.sparkleColor = const Color(0xFFFBBF24), // Gold
    this.sparkleCount = 12,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.sparkleCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index % 3) * 200),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          weight: 0.3,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0),
          weight: 0.7,
        ),
      ]).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    if (widget.active) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (var controller in _controllers) {
      controller.repeat();
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startAnimation();
    } else if (!widget.active && oldWidget.active) {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (widget.active)
          ...List.generate(widget.sparkleCount, (index) {
            final angle = (2 * math.pi * index) / widget.sparkleCount;
            final radius = 40.0;
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final x = math.cos(angle) * radius;
                final y = math.sin(angle) * radius;
                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: _animations[index].value,
                    child: Transform.scale(
                      scale: _animations[index].value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.sparkleColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.sparkleColor.withValues(
                                alpha: 0.8,
                              ),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}

/// XP gain sparkle animation
class XpSparkleAnimation extends StatefulWidget {
  final int xpAmount;
  final VoidCallback? onComplete;

  const XpSparkleAnimation({
    super.key,
    required this.xpAmount,
    this.onComplete,
  });

  @override
  State<XpSparkleAnimation> createState() => _XpSparkleAnimationState();
}

class _XpSparkleAnimationState extends State<XpSparkleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 0.5,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 0.3,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -50),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _positionAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.xpAmount} XP',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


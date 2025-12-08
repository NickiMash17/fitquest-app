// lib/shared/widgets/premium_loading_widget.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'dart:math' as math;

/// Premium loading widget with animated particles
class PremiumLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;

  const PremiumLoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  State<PremiumLoadingWidget> createState() => _PremiumLoadingWidgetState();
}

class _PremiumLoadingWidgetState extends State<PremiumLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primaryGreen;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Pulsing center circle
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Particles
              ...List.generate(8, (index) {
                return AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final angle = (index * math.pi * 2 / 8) +
                        (_particleController.value * 2 * math.pi);
                    final radius = 40 + (math.sin(_particleController.value * math.pi) * 10);
                    final x = math.cos(angle) * radius;
                    final y = math.sin(angle) * radius;
                    final opacity = 0.3 + (math.sin(_particleController.value * math.pi) * 0.7);

                    return Positioned(
                      left: 40 + x,
                      top: 40 + y,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.8),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading effect for cards
class ShimmerCard extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.1);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.grey.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}


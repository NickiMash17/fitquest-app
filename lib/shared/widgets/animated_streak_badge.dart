// lib/shared/widgets/animated_streak_badge.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Animated streak badge with pulsing flame icon
/// Phase 2: Streak flame pulse animation
class AnimatedStreakBadge extends StatefulWidget {
  final int streak;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  const AnimatedStreakBadge({
    super.key,
    required this.streak,
    this.padding,
    this.textStyle,
  });

  @override
  State<AnimatedStreakBadge> createState() => _AnimatedStreakBadgeState();
}

class _AnimatedStreakBadgeState extends State<AnimatedStreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _flameAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _flameController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.xp,
            AppColors.xp.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: AppBorderRadius.allXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.xp.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated flame icon
          AnimatedBuilder(
            animation: _flameAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _flameAnimation.value,
                child: Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.orange.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Counter with number animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              '${widget.streak} day streak!',
              key: ValueKey(widget.streak),
              style: widget.textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

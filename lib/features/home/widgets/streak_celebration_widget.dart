// lib/features/home/widgets/streak_celebration_widget.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/core/constants/app_typography.dart';

/// Celebration widget for streak milestones
class StreakCelebrationWidget extends StatefulWidget {
  final int streak;
  final VoidCallback? onDismiss;

  const StreakCelebrationWidget({
    super.key,
    required this.streak,
    this.onDismiss,
  });

  @override
  State<StreakCelebrationWidget> createState() =>
      _StreakCelebrationWidgetState();
}

class _StreakCelebrationWidgetState extends State<StreakCelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late ConfettiController _confettiController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
    _confettiController.play();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isVisible) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (!_isVisible) return;
    setState(() => _isVisible = false);
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getMilestoneMessage() {
    if (widget.streak >= 100) {
      return '🏆 LEGENDARY! ${widget.streak} days of dedication!';
    } else if (widget.streak >= 50) {
      return '🌟 INCREDIBLE! ${widget.streak} days strong!';
    } else if (widget.streak >= 30) {
      return '🔥 AMAZING! ${widget.streak}-day streak!';
    } else if (widget.streak >= 14) {
      return '💪 TWO WEEKS! ${widget.streak} days of consistency!';
    } else if (widget.streak >= 7) {
      return '✨ ONE WEEK! ${widget.streak} days strong!';
    } else if (widget.streak >= 3) {
      return '🌱 BUILDING! ${widget.streak}-day streak!';
    }
    return '🎉 ${widget.streak}-day streak!';
  }

  Gradient _getMilestoneGradient() {
    if (widget.streak >= 50) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
      );
    } else if (widget.streak >= 30) {
      return const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
      );
    } else if (widget.streak >= 7) {
      return AppColors.accentGradient;
    }
    return AppColors.primaryGradient;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PremiumCard(
              padding: const EdgeInsets.all(24.0),
              gradient: _getMilestoneGradient(),
              showShadow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMilestoneMessage(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the momentum going!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _dismiss,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.allMD,
                      ),
                    ),
                    child: Text(
                      'Awesome!',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Confetti overlay
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57,
                  maxBlastForce: 8,
                  minBlastForce: 3,
                  emissionFrequency: 0.03,
                  numberOfParticles: 30,
                  gravity: 0.2,
                  colors: [
                    Colors.white,
                    AppColors.primaryGreen,
                    AppColors.accentOrange,
                    AppColors.accentBlue,
                    const Color(0xFFFFD700),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

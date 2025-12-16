// lib/shared/widgets/achievement_unlock_overlay.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';
import 'package:fitquest/shared/widgets/sparkle_effect.dart';
import 'dart:math' as math;

/// Full-screen achievement unlock celebration overlay
/// Phase 4: Achievement unlock animation
class AchievementUnlockOverlay extends StatefulWidget {
  final String achievementName;
  final String achievementDescription;
  final IconData achievementIcon;
  final Color achievementColor;
  final int xpReward;
  final VoidCallback? onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievementName,
    required this.achievementDescription,
    required this.achievementIcon,
    this.achievementColor = const Color(0xFFF5C518), // XP gold
    this.xpReward = 0,
    this.onDismiss,
  });

  /// Show achievement unlock overlay
  static void show(
    BuildContext context, {
    required String achievementName,
    required String achievementDescription,
    required IconData achievementIcon,
    Color achievementColor = const Color(0xFFF5C518), // XP gold
    int xpReward = 0,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AchievementUnlockOverlay(
        achievementName: achievementName,
        achievementDescription: achievementDescription,
        achievementIcon: achievementIcon,
        achievementColor: achievementColor,
        xpReward: xpReward,
        onDismiss: () {
          entry.remove();
          onDismiss?.call();
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for achievement card
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 0.7,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Fade animation for background
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _confettiController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _confettiController.forward();

    // Haptic feedback
    HapticFeedbackService.heavyImpact();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          _fadeController.reverse().then((_) {
            widget.onDismiss?.call();
          });
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _fadeAnimation,
            _scaleAnimation,
            _confettiAnimation,
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                // Darkened background
                Opacity(
                  opacity: _fadeAnimation.value * 0.8,
                  child: Container(
                    color: Colors.black,
                  ),
                ),

                // Confetti particles
                _ConfettiLayer(
                  animationValue: _confettiAnimation.value,
                  color: widget.achievementColor,
                ),

                // Achievement card
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _AchievementCard(
                        achievementName: widget.achievementName,
                        achievementDescription: widget.achievementDescription,
                        achievementIcon: widget.achievementIcon,
                        achievementColor: widget.achievementColor,
                        xpReward: widget.xpReward,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String achievementName;
  final String achievementDescription;
  final IconData achievementIcon;
  final Color achievementColor;
  final int xpReward;

  const _AchievementCard({
    required this.achievementName,
    required this.achievementDescription,
    required this.achievementIcon,
    required this.achievementColor,
    required this.xpReward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            achievementColor,
            achievementColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: AppBorderRadius.allXL,
        boxShadow: [
          BoxShadow(
            color: achievementColor.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sparkle effect around icon
          SparkleEffect(
            active: true,
            sparkleColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievementIcon,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Achievement Unlocked!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            achievementName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            achievementDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
          if (xpReward > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppBorderRadius.allMD,
              ),
              child: Text(
                '+$xpReward XP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfettiLayer extends StatelessWidget {
  final double animationValue;
  final Color color;

  const _ConfettiLayer({
    required this.animationValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _ConfettiPainter(
        animationValue: animationValue,
        color: color,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _ConfettiPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    final particleCount = 50;

    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (1 - animationValue) +
          random.nextDouble() * size.height * animationValue;
      final particleSize = 4 + random.nextDouble() * 6;
      final rotation = animationValue * 2 * math.pi * random.nextDouble();

      final paint = Paint()
        ..color = color.withValues(
          alpha: (1 - animationValue).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw confetti shape (square or circle)
      if (random.nextBool()) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, particleSize / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}


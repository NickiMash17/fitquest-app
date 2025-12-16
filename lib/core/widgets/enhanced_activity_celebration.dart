// lib/core/widgets/enhanced_activity_celebration.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/services/haptic_service.dart';
import 'package:fitquest/shared/widgets/floating_xp_number.dart';

/// Enhanced celebration system for activity logging
/// Combines multiple animations for maximum impact
class EnhancedActivityCelebration {
  /// Show full celebration sequence when activity is logged
  static void show(
    BuildContext context,
    int xpEarned,
    int pointsEarned, {
    Offset? startPosition,
    VoidCallback? onComplete,
  }) {
    debugPrint('🎉 EnhancedActivityCelebration.show called - XP: $xpEarned, Points: $pointsEarned');
    
    // Haptic feedback
    try {
      HapticService.success();
      debugPrint('✅ Haptic feedback triggered');
    } catch (e) {
      debugPrint('⚠️ Haptic feedback error: $e');
    }
    
    // Get screen center if no position provided
    final position = startPosition ?? 
        Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        );

    debugPrint('📍 Celebration position: $position');

    // Show celebration overlay with confetti
    _showCelebrationOverlay(context, xpEarned, pointsEarned, onComplete);
    
    // Show floating XP numbers (multiple for visual impact)
    _showFloatingNumbers(context, xpEarned, pointsEarned, position);
    
    // Trigger confetti burst
    _showConfettiBurst(context);
    
    debugPrint('✅ All celebration animations triggered');
  }

  /// Show celebration overlay dialog
  static void _showCelebrationOverlay(
    BuildContext context,
    int xpEarned,
    int pointsEarned,
    VoidCallback? onComplete,
  ) {
    debugPrint('🎊 Showing celebration overlay dialog');
    try {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        barrierDismissible: false,
        builder: (context) {
          debugPrint('🎊 Building celebration dialog');
          return _CelebrationDialog(
            xpEarned: xpEarned,
            pointsEarned: pointsEarned,
            onComplete: onComplete,
          );
        },
      );
      debugPrint('✅ Celebration dialog shown');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing celebration dialog: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback to snackbar if dialog fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$xpEarned XP earned! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      onComplete?.call();
    }
  }

  /// Show multiple floating XP numbers for visual impact
  static void _showFloatingNumbers(
    BuildContext context,
    int xpEarned,
    int pointsEarned,
    Offset center,
  ) {
    debugPrint('💫 Showing floating numbers at $center');
    try {
      // Show XP number (left side)
      FloatingXpNumber.show(
        context,
        xpEarned,
        Offset(center.dx - 80, center.dy - 120),
        label: 'XP',
        color: AppColors.xp,
      );
      debugPrint('✅ Floating XP number shown');

      // Show points number (right side) with slight delay
      Future.delayed(const Duration(milliseconds: 150), () {
        if (context.mounted) {
          FloatingXpNumber.show(
            context,
            pointsEarned,
            Offset(center.dx + 80, center.dy - 120),
            label: 'Points',
            color: AppColors.accentOrange,
          );
          debugPrint('✅ Floating Points number shown');
        }
      });

      // Show additional sparkle effect numbers (smaller, faster)
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: 100 + (i * 100)), () {
          if (context.mounted) {
            final offset = Offset(
              center.dx + (i - 1) * 40,
              center.dy - 80 - (i * 20),
            );
            FloatingXpNumber.show(
              context,
              xpEarned ~/ 10, // Smaller number for sparkles
              offset,
              label: '✨',
              color: Colors.white,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error showing floating numbers: $e');
    }
  }

  /// Show confetti burst animation
  static void _showConfettiBurst(BuildContext context) {
    debugPrint('🎊 Showing confetti burst');
    try {
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      
      entry = OverlayEntry(
        builder: (context) => _ConfettiBurst(
          onComplete: () {
            debugPrint('✅ Confetti burst complete');
            entry.remove();
          },
        ),
      );
      
      overlay.insert(entry);
      debugPrint('✅ Confetti burst overlay inserted');
    } catch (e) {
      debugPrint('❌ Error showing confetti: $e');
    }
  }
}

/// Celebration dialog with animations
class _CelebrationDialog extends StatefulWidget {
  final int xpEarned;
  final int pointsEarned;
  final VoidCallback? onComplete;

  const _CelebrationDialog({
    required this.xpEarned,
    required this.pointsEarned,
    this.onComplete,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎊 _CelebrationDialog initState - Starting animations');

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Scale animation for main card
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation for icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    debugPrint('🎊 _CelebrationDialog initState - Starting animations');
    try {
      _confettiController.play();
      debugPrint('✅ Confetti controller played');
    } catch (e) {
      debugPrint('❌ Confetti controller error: $e');
    }
    
    _scaleController.forward();
    debugPrint('✅ Scale controller forwarded');

    // Auto-close after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        debugPrint('🎊 Auto-closing celebration dialog');
        Navigator.of(context).pop();
        widget.onComplete?.call();
      } else {
        debugPrint('⚠️ Widget not mounted, skipping auto-close');
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎊 _CelebrationDialog build() called');
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti burst from center (only if not web)
          if (!kIsWeb)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 15,
                  minBlastForce: 8,
                  emissionFrequency: 0.05,
                  numberOfParticles: 80,
                  gravity: 0.2,
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.accentOrange,
                    AppColors.accentBlue,
                    AppColors.accentPurple,
                    Colors.white,
                    Colors.yellow,
                  ],
                ),
              ),
            )
          else
            // Fallback: Animated particles for web
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticlePainter(
                        progress: _sparkleController.value,
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.accentOrange,
                          AppColors.accentBlue,
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Main celebration card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sparkle effects around icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating star icon
                          AnimatedBuilder(
                            animation: _rotationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value * 0.2,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Sparkle particles
                          ...List.generate(8, (index) {
                            final angle = (index * 2 * math.pi) / 8;
                            return AnimatedBuilder(
                              animation: _sparkleController,
                              builder: (context, child) {
                                final distance = 60 + 
                                    (math.sin(_sparkleController.value * 2 * math.pi + angle) * 10);
                                final x = math.cos(angle) * distance;
                                final y = math.sin(angle) * distance;
                                final opacity = 0.5 + 
                                    (math.sin(_sparkleController.value * 2 * math.pi + angle) * 0.5);

                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
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
                      const SizedBox(height: 24),
                      // XP earned
                      Text(
                        '+${widget.xpEarned} XP',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Points earned
                      Text(
                        '+${widget.pointsEarned} Points',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Success message
                      Text(
                        'Great job! 🌱',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Confetti burst overlay
class _ConfettiBurst extends StatefulWidget {
  final VoidCallback onComplete;

  const _ConfettiBurst({required this.onComplete});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _controller.play();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Top confetti (only if not web)
          if (!kIsWeb)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controller,
                blastDirection: math.pi / 2,
                maxBlastForce: 12,
                minBlastForce: 6,
                emissionFrequency: 0.03,
                numberOfParticles: 60,
                gravity: 0.3,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.accentOrange,
                  AppColors.accentBlue,
                  Colors.white,
                  Colors.yellow,
                ],
              ),
            ),
          // Bottom confetti (only if not web)
          if (!kIsWeb)
            Align(
              alignment: Alignment.bottomCenter,
              child: ConfettiWidget(
                confettiController: _controller,
                blastDirection: -math.pi / 2,
                maxBlastForce: 12,
                minBlastForce: 6,
                emissionFrequency: 0.03,
                numberOfParticles: 60,
                gravity: -0.3,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.accentOrange,
                  AppColors.accentBlue,
                  Colors.white,
                  Colors.yellow,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom particle painter for web fallback
class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _ParticlePainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 50; i++) {
      final angle = (i * 2 * math.pi) / 50;
      final distance = 100 * progress;
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = size.height / 2 + math.sin(angle) * distance;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final colorIndex = i % colors.length;

      paint.color = colors[colorIndex].withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x, y),
        4 + (random.nextDouble() * 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => 
      oldDelegate.progress != progress;
}

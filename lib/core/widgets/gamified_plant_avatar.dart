// lib/core/widgets/gamified_plant_avatar.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_dimensions.dart';
import 'package:fitquest/core/constants/app_durations.dart';
import 'package:fitquest/core/constants/app_typography.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/services/haptic_service.dart';
import 'package:fitquest/features/home/data/models/wellness_data.dart';
import 'package:fitquest/features/home/domain/entities/tree_stage.dart';
import 'package:fitquest/features/home/domain/usecases/calculate_tree_stage.dart';

/// Gamified Plant Avatar with personality, emotions, and interactive features
/// Inspired by Offerzen's plant companion system
class GamifiedPlantAvatar extends StatefulWidget {
  final int level;
  final WellnessData wellnessData;
  final VoidCallback? onTap;
  final bool showPersonality;
  final double size;

  const GamifiedPlantAvatar({
    super.key,
    required this.level,
    required this.wellnessData,
    this.onTap,
    this.showPersonality = true,
    this.size = 200,
  });

  @override
  State<GamifiedPlantAvatar> createState() => _GamifiedPlantAvatarState();
}

class _GamifiedPlantAvatarState extends State<GamifiedPlantAvatar>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _emotionController;
  late AnimationController _celebrationController;
  late Animation<double> _idleAnimation;
  late Animation<double> _emotionAnimation;
  late Animation<double> _celebrationAnimation;

  PlantEmotion _currentEmotion = PlantEmotion.happy;
  TreeStage? _currentStage;

  @override
  void initState() {
    super.initState();
    _currentStage = TreeCalculator.getStageForLevel(
      widget.level,
      widget.wellnessData,
    );
    _initializeAnimations(); // Initialize controllers FIRST
    _calculateEmotion(); // Then calculate emotion (which may use controllers)
  }

  void _initializeAnimations() {
    // Idle animation - gentle breathing/swaying
    _idleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _idleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );

    // Emotion animation - reacts to wellness state
    _emotionController = AnimationController(
      duration: AppDurations.moderate,
      vsync: this,
    );

    _emotionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emotionController,
        curve: AppDurations.standardCurve,
      ),
    );
    
    // Start emotion animation after initialization
    _emotionController.forward(from: 0);

    // Celebration animation - on level up or milestone
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _calculateEmotion() {
    final overallScore = _calculateOverallScore();
    final previousEmotion = _currentEmotion;

    if (overallScore >= 0.9) {
      _currentEmotion = PlantEmotion.ecstatic;
    } else if (overallScore >= 0.75) {
      _currentEmotion = PlantEmotion.happy;
    } else if (overallScore >= 0.6) {
      _currentEmotion = PlantEmotion.content;
    } else if (overallScore >= 0.4) {
      _currentEmotion = PlantEmotion.neutral;
    } else if (overallScore >= 0.2) {
      _currentEmotion = PlantEmotion.sad;
    } else {
      _currentEmotion = PlantEmotion.worried;
    }

    // Animate emotion change (only if controller is initialized)
    if (previousEmotion != _currentEmotion) {
      _emotionController.forward(from: 0);
    }
  }

  double _calculateOverallScore() {
    // Calculate progress from wellness data
    final exerciseProgress = widget.wellnessData.exerciseCompleted ? 1.0 : widget.wellnessData.exerciseConsistency;
    final meditationProgress = widget.wellnessData.meditationCompleted ? 1.0 : (widget.wellnessData.meditationMinutes / 20.0).clamp(0.0, 1.0);
    final hydrationProgress = widget.wellnessData.hydrationCompleted ? 1.0 : (widget.wellnessData.hydrationLevel).clamp(0.0, 1.0);
    final sleepProgress = widget.wellnessData.sleepCompleted ? 1.0 : (widget.wellnessData.sleepQuality).clamp(0.0, 1.0);
    
    return (exerciseProgress + meditationProgress + hydrationProgress + sleepProgress) / 4.0;
  }

  @override
  void didUpdateWidget(GamifiedPlantAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for level up (only if controllers are initialized)
    if (widget.level > oldWidget.level) {
      _currentStage = TreeCalculator.getStageForLevel(
        widget.level,
        widget.wellnessData,
      );
      try {
        _triggerCelebration();
        HapticService.success();
      } catch (e) {
        // Controllers not ready yet, skip celebration
        debugPrint('Celebration skipped: $e');
      }
    }

    // Recalculate emotion
    _calculateEmotion();
  }

  void _triggerCelebration() {
    try {
      _celebrationController.forward(from: 0).then((_) {
        if (mounted) {
          _celebrationController.reverse();
        }
      });
    } catch (e) {
      debugPrint('Celebration error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check: ensure controllers are initialized before building
    try {
      // Access controllers to trigger error early if not initialized
      final _ = _idleController;
      final __ = _emotionController;
      final ___ = _celebrationController;
    } catch (e) {
      debugPrint('Controllers not initialized in build: $e');
      // Return empty widget if not ready
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        HapticService.light();
        widget.onTap?.call();
        _showPersonalityDialog();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getEmotionColor().withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow based on emotion
            AnimatedBuilder(
              animation: _idleAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getEmotionColor().withValues(alpha: 0.2 * _idleAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Main plant avatar
            AnimatedBuilder(
              animation: Listenable.merge([
                _idleAnimation,
                _emotionAnimation,
                _celebrationAnimation,
              ]),
              builder: (context, child) {
                final scale = 1.0 +
                    (_celebrationAnimation.value * 0.2) +
                    (math.sin(_idleAnimation.value * math.pi * 2) * 0.05);
                final rotation = math.sin(_idleAnimation.value * math.pi * 2) *
                    0.1 *
                    (1 - _celebrationAnimation.value);

                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotation,
                    child: CustomPaint(
                      painter: _PlantAvatarPainter(
                        stage: _currentStage!,
                        emotion: _currentEmotion,
                        emotionProgress: _emotionAnimation.value,
                        wellnessData: widget.wellnessData,
                      ),
                      size: Size(widget.size, widget.size),
                    ),
                  ),
                );
              },
            ),

            // Personality indicator (if enabled)
            if (widget.showPersonality)
              Positioned(
                bottom: 8,
                child: _buildPersonalityIndicator(),
              ),

            // Level badge
            Positioned(
              top: 8,
              child: _buildLevelBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityIndicator() {
    final message = _getPersonalityMessage();
    if (message.isEmpty) return const SizedBox.shrink();

    // Don't show personality indicator if wellness is very low (to avoid confusion with errors)
    final overallScore = _calculateOverallScore();
    if (overallScore < 0.3) {
      return const SizedBox.shrink(); // Hide when wellness is very low
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getEmotionColor().withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.elevation2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEmotionIcon(),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            message,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGoldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.premiumGlow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.eco,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'Lv.${widget.level}',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor() {
    switch (_currentEmotion) {
      case PlantEmotion.ecstatic:
        return AppColors.premiumGold;
      case PlantEmotion.happy:
        return AppColors.primaryGreen.shade400;
      case PlantEmotion.content:
        return AppColors.accentGreen;
      case PlantEmotion.neutral:
        return AppColors.textSecondary;
      case PlantEmotion.sad:
        return AppColors.warning;
      case PlantEmotion.worried:
        return AppColors.error;
    }
  }

  IconData _getEmotionIcon() {
    switch (_currentEmotion) {
      case PlantEmotion.ecstatic:
        return Icons.celebration;
      case PlantEmotion.happy:
        return Icons.mood;
      case PlantEmotion.content:
        return Icons.sentiment_satisfied;
      case PlantEmotion.neutral:
        return Icons.sentiment_neutral;
      case PlantEmotion.sad:
        return Icons.sentiment_dissatisfied;
      case PlantEmotion.worried:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String _getPersonalityMessage() {
    final overallScore = _calculateOverallScore();

    if (overallScore >= 0.9) {
      return 'Amazing! 🌟';
    } else if (overallScore >= 0.75) {
      return 'Great job! 💪';
    } else if (overallScore < 0.4) {
      return 'Keep going! 🌱'; // Changed from "Need help?" to avoid confusion
    }
    return '';
  }

  void _showPersonalityDialog() {
    showDialog(
      context: context,
      builder: (context) => _PersonalityDialog(
        emotion: _currentEmotion,
        level: widget.level,
        wellnessData: widget.wellnessData,
      ),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _emotionController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}

enum PlantEmotion {
  ecstatic,
  happy,
  content,
  neutral,
  sad,
  worried,
}

class _PlantAvatarPainter extends CustomPainter {
  final TreeStage stage;
  final PlantEmotion emotion;
  final double emotionProgress;
  final WellnessData wellnessData;

  _PlantAvatarPainter({
    required this.stage,
    required this.emotion,
    required this.emotionProgress,
    required this.wellnessData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw based on stage and emotion
    _drawPlant(canvas, center, radius);
    _drawEmotion(canvas, center, radius);
  }

  void _drawPlant(Canvas canvas, Offset center, double radius) {
    // Simplified plant drawing - can be enhanced with more detail
    final trunkPaint = Paint()
      ..color = AppColors.treeTrunk
      ..style = PaintingStyle.fill;

    final leavesPaint = Paint()
      ..color = _getEmotionColor()
      ..style = PaintingStyle.fill;

    // Trunk
    final trunkWidth = stage.trunkWidth;
    final trunkHeight = radius * 0.6 * stage.trunkHeightRatio;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.2),
          width: trunkWidth,
          height: trunkHeight,
        ),
        const Radius.circular(4),
      ),
      trunkPaint,
    );

    // Canopy (leaves)
    final canopyRadius = radius * 0.7 * stage.canopyRadiusRatio;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      canopyRadius,
      leavesPaint,
    );
  }

  void _drawEmotion(Canvas canvas, Offset center, double radius) {
    // Draw emotion-based effects (sparkles, particles, etc.)
    if (emotion == PlantEmotion.ecstatic || emotion == PlantEmotion.happy) {
      final sparklePaint = Paint()
        ..color = AppColors.premiumGold.withValues(alpha: 0.8 * emotionProgress)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi * 2 / 8) + (emotionProgress * math.pi * 2);
        final x = center.dx + math.cos(angle) * radius * 0.8;
        final y = center.dy + math.sin(angle) * radius * 0.8;
        canvas.drawCircle(Offset(x, y), 3, sparklePaint);
      }
    }
  }

  Color _getEmotionColor() {
    switch (emotion) {
      case PlantEmotion.ecstatic:
        return AppColors.premiumGold;
      case PlantEmotion.happy:
        return AppColors.primaryGreen.shade400;
      case PlantEmotion.content:
        return AppColors.accentGreen;
      case PlantEmotion.neutral:
        return AppColors.textSecondary;
      case PlantEmotion.sad:
        return AppColors.warning;
      case PlantEmotion.worried:
        return AppColors.error;
    }
  }

  @override
  bool shouldRepaint(_PlantAvatarPainter oldDelegate) {
    return oldDelegate.emotion != emotion ||
        oldDelegate.emotionProgress != emotionProgress ||
        oldDelegate.stage != stage;
  }
}

class _PersonalityDialog extends StatelessWidget {
  final PlantEmotion emotion;
  final int level;
  final WellnessData wellnessData;

  const _PersonalityDialog({
    required this.emotion,
    required this.level,
    required this.wellnessData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
      child: Padding(
        padding: AppDimensions.paddingXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPersonalityTitle(),
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getPersonalityMessage(),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPersonalityTitle() {
    switch (emotion) {
      case PlantEmotion.ecstatic:
        return '🌟 Amazing Progress!';
      case PlantEmotion.happy:
        return '😊 Great Job!';
      case PlantEmotion.content:
        return '🌱 Keep Growing!';
      case PlantEmotion.neutral:
        return '🌿 Steady Progress';
      case PlantEmotion.sad:
        return '💧 Need Some Care';
      case PlantEmotion.worried:
        return '🌱 Let\'s Get Back on Track';
    }
  }

  String _getPersonalityMessage() {

    switch (emotion) {
      case PlantEmotion.ecstatic:
        return 'You\'re doing absolutely amazing! Your plant is thriving and so proud of you!';
      case PlantEmotion.happy:
        return 'You\'re on a great path! Keep up the excellent work!';
      case PlantEmotion.content:
        return 'You\'re making steady progress. Every step counts!';
      case PlantEmotion.neutral:
        return 'You\'re doing okay, but there\'s room to grow. Let\'s aim higher!';
      case PlantEmotion.sad:
        return 'Your plant needs some attention. Let\'s complete some activities today!';
      case PlantEmotion.worried:
        return 'Your plant is worried. Let\'s get back on track with your wellness goals!';
    }
  }
}


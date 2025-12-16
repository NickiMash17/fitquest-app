// lib/core/widgets/premium_tree_canvas.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/constants/app_dimensions.dart';
import 'package:fitquest/core/constants/app_durations.dart';
import 'package:fitquest/core/constants/app_typography.dart';
import 'package:fitquest/core/services/haptic_service.dart';
import 'package:fitquest/features/home/data/models/wellness_data.dart';
import 'package:fitquest/features/home/domain/entities/tree_stage.dart';
import 'package:fitquest/features/home/domain/usecases/calculate_tree_stage.dart';

/// Production-Grade Tree Canvas with premium animations and effects
class PremiumTreeCanvas extends StatefulWidget {
  final int level;
  final WellnessData wellnessData;
  final bool isAnimating;

  const PremiumTreeCanvas({
    super.key,
    required this.level,
    required this.wellnessData,
    this.isAnimating = false,
  });

  @override
  State<PremiumTreeCanvas> createState() => _PremiumTreeCanvasState();
}

class _PremiumTreeCanvasState extends State<PremiumTreeCanvas>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _growthController;
  late AnimationController _particleController;

  // Cache expensive calculations
  late TreeStage _currentStage;
  final Map<String, Path> _pathCache = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _calculateTreeStage();
  }

  void _initializeAnimations() {
    // Continuous sway animation
    _swayController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Growth animation on level up
    _growthController = AnimationController(
      duration: AppDurations.treeGrowth,
      vsync: this,
    );

    // Particle effects
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  void _calculateTreeStage() {
    _currentStage = TreeCalculator.getStageForLevel(
      widget.level,
      widget.wellnessData,
    );
  }

  @override
  void didUpdateWidget(PremiumTreeCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.level != oldWidget.level) {
      _calculateTreeStage();
      _growthController.forward(from: 0);
      HapticService.heavy();
      // Trigger celebration animation
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(isDark),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.elevation2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Stack(
          children: [
            // Background elements (sun/moon, clouds)
            _buildBackgroundElements(),

            // Main tree
            AnimatedBuilder(
              animation: Listenable.merge([
                _swayController,
                _growthController,
              ]),
              builder: (context, child) {
                return Transform.rotate(
                  angle: math.sin(_swayController.value * 2 * math.pi) * 0.02,
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        painter: TreePainter(
                          stage: _currentStage,
                          wellnessData: widget.wellnessData,
                          growthProgress: _growthController.value,
                          pathCache: _pathCache,
                          isDark: isDark,
                        ),
                        size: Size(
                          constraints.maxWidth.isFinite
                              ? constraints.maxWidth
                              : 400,
                          constraints.maxHeight.isFinite
                              ? constraints.maxHeight
                              : 280,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Wellness indicators (small icons on tree)
            _buildWellnessIndicators(),

            // Particle effects
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: ParticlePainter(
                        progress: _particleController.value,
                        wellnessData: widget.wellnessData,
                        isDark: isDark,
                      ),
                      size: Size(
                        constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : 400,
                        constraints.maxHeight.isFinite
                            ? constraints.maxHeight
                            : 280,
                      ),
                    );
                  },
                );
              },
            ),

            // Level badge overlay
            Positioned(
              top: 16,
              right: 16,
              child: _buildLevelBadge(),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getBackgroundGradient(bool isDark) {
    final hour = DateTime.now().hour;

    if (isDark) {
      // Dark theme gradients - deeper, richer colors
      if (hour >= 5 && hour < 7) {
        return [
          const Color(0xFF4A2C1A),
          const Color(0xFF5A3A2A),
          const Color(0xFF1A1A2E),
        ];
      } else if (hour >= 7 && hour < 17) {
        return [
          const Color(0xFF1A3A4A),
          const Color(0xFF2A4A5A),
          const Color(0xFF1A1A2E),
        ];
      } else if (hour >= 17 && hour < 20) {
        return [
          const Color(0xFF4A2A1A),
          const Color(0xFF5A3A2A),
          const Color(0xFF1A1A2E),
        ];
      } else {
        return [
          const Color(0xFF0A0A1A),
          const Color(0xFF1A1A2E),
          const Color(0xFF2A2A3A),
        ];
      }
    }

    // Dawn (5-7)
    if (hour >= 5 && hour < 7) {
      return [
        const Color(0xFFFFB347),
        const Color(0xFFFFCC99),
        const Color(0xFFE8F5E9),
      ];
    }
    // Day (7-17)
    else if (hour >= 7 && hour < 17) {
      return [
        const Color(0xFF87CEEB),
        const Color(0xFFB3D9E6),
        const Color(0xFFE8F5E9),
      ];
    }
    // Dusk (17-20)
    else if (hour >= 17 && hour < 20) {
      return [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFB347),
        const Color(0xFFE8F5E9),
      ];
    }
    // Night (20-5)
    else {
      return [
        const Color(0xFF1A1A2E),
        const Color(0xFF2D3561),
        const Color(0xFF4A5568),
      ];
    }
  }

  Widget _buildBackgroundElements() {
    // Simple background elements - can be enhanced
    return Container();
  }

  Widget _buildWellnessIndicators() {
    final indicators = <Widget>[];

    // Exercise indicator
    if (widget.wellnessData.exerciseCompleted) {
      indicators.add(
        const Positioned(
          left: 60,
          top: 80,
          child: _WellnessIndicatorDot(
            color: AppColors.exerciseAccent,
            icon: Icons.fitness_center,
            size: 24,
          ),
        ),
      );
    }

    // Meditation indicator
    if (widget.wellnessData.meditationCompleted) {
      indicators.add(
        const Positioned(
          right: 60,
          top: 80,
          child: _WellnessIndicatorDot(
            color: AppColors.meditationAccent,
            icon: Icons.self_improvement,
            size: 24,
          ),
        ),
      );
    }

    // Hydration indicator
    if (widget.wellnessData.hydrationCompleted) {
      indicators.add(
        const Positioned(
          left: 80,
          top: 140,
          child: _WellnessIndicatorDot(
            color: AppColors.hydrationAccent,
            icon: Icons.water_drop,
            size: 24,
          ),
        ),
      );
    }

    // Sleep indicator
    if (widget.wellnessData.sleepCompleted) {
      indicators.add(
        const Positioned(
          right: 80,
          top: 140,
          child: _WellnessIndicatorDot(
            color: AppColors.sleepAccent,
            icon: Icons.nightlight_round,
            size: 24,
          ),
        ),
      );
    }

    return Stack(children: indicators);
  }

  Widget _buildLevelBadge() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final borderColor = isDark
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.3);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: AppDurations.moderate,
          curve: AppDurations.bounceCurve,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGoldGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.premiumGlow,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Level ${widget.level}',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _swayController.dispose();
    _growthController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

// Tree Painter with production-grade rendering
class TreePainter extends CustomPainter {
  final TreeStage stage;
  final WellnessData wellnessData;
  final double growthProgress;
  final Map<String, Path> pathCache;
  final bool isDark;

  TreePainter({
    required this.stage,
    required this.wellnessData,
    required this.growthProgress,
    required this.pathCache,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    // Draw shadow
    _drawShadow(canvas, centerX, groundY);

    // Draw trunk with exercise-based thickness
    _drawTrunk(canvas, centerX, groundY, size);

    // Draw branches and leaves with meditation-based fullness
    _drawCanopy(canvas, centerX, groundY, size);

    // Draw flowers/fruits based on hydration
    if (wellnessData.hydrationLevel > 0.7) {
      _drawFlowers(canvas, centerX, groundY, size);
    }

    // Add glow effect based on sleep quality
    if (wellnessData.sleepQuality > 0.7) {
      _drawGlow(canvas, centerX, groundY, size);
    }
  }

  void _drawTrunk(Canvas canvas, double centerX, double groundY, Size size) {
    final trunkWidth = _calculateTrunkWidth();
    final trunkHeight = _calculateTrunkHeight(size);

    final path = Path();
    path.moveTo(centerX - trunkWidth / 2, groundY);
    path.quadraticBezierTo(
      centerX - trunkWidth / 3,
      groundY - trunkHeight / 2,
      centerX - trunkWidth / 4,
      groundY - trunkHeight,
    );
    path.lineTo(centerX + trunkWidth / 4, groundY - trunkHeight);
    path.quadraticBezierTo(
      centerX + trunkWidth / 3,
      groundY - trunkHeight / 2,
      centerX + trunkWidth / 2,
      groundY,
    );
    path.close();

    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.treeTrunk,
          AppColors.treeTrunk.withOpacity(0.8),
          AppColors.treeTrunk,
        ],
      ).createShader(path.getBounds())
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, trunkPaint);

    // Draw bark texture
    _drawBarkTexture(canvas, path);
  }

  void _drawCanopy(Canvas canvas, double centerX, double groundY, Size size) {
    final canopyRadius = _calculateCanopyRadius(size);
    final canopyY = groundY - _calculateTrunkHeight(size) - canopyRadius / 2;

    // Layer multiple leaf clusters for depth
    const layers = 3;
    for (int i = layers; i > 0; i--) {
      final layerRadius = canopyRadius * (0.6 + (i * 0.2));

      final leafPaint = Paint()
        ..color = _getLeafColor(i, layers)
        ..style = PaintingStyle.fill;

      // Draw organic leaf shapes
      final leafPath = _createOrganicCircle(
        centerX,
        canopyY,
        layerRadius,
        12, // number of irregularities
      );

      canvas.drawPath(leafPath, leafPaint);
    }
  }

  Path _createOrganicCircle(
    double centerX,
    double centerY,
    double radius,
    int points,
  ) {
    final path = Path();
    final angleStep = (2 * math.pi) / points;
    final random = math.Random(42); // Consistent seed

    for (int i = 0; i <= points; i++) {
      final angle = i * angleStep;
      final variance = radius * (0.85 + random.nextDouble() * 0.3);
      final x = centerX + math.cos(angle) * variance;
      final y = centerY + math.sin(angle) * variance;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevAngle = (i - 1) * angleStep;
        final prevX = centerX + math.cos(prevAngle) * variance;
        final prevY = centerY + math.sin(prevAngle) * variance;

        // Use quadratic bezier for smooth curves
        final cpX = (x + prevX) / 2 + (random.nextDouble() - 0.5) * 10;
        final cpY = (y + prevY) / 2 + (random.nextDouble() - 0.5) * 10;

        path.quadraticBezierTo(cpX, cpY, x, y);
      }
    }

    path.close();
    return path;
  }

  double _calculateTrunkWidth() {
    // Base calculation on exercise consistency
    final baseWidth = stage.trunkWidth;
    final exerciseMultiplier = 0.8 + (wellnessData.exerciseConsistency * 0.4);
    return baseWidth * exerciseMultiplier * growthProgress;
  }

  double _calculateTrunkHeight(Size size) {
    return size.height * stage.trunkHeightRatio * growthProgress;
  }

  double _calculateCanopyRadius(Size size) {
    // Based on meditation regularity
    final baseRadius = size.width * stage.canopyRadiusRatio;
    final meditationMultiplier =
        0.7 + (wellnessData.meditationRegularity * 0.6);
    return baseRadius * meditationMultiplier * growthProgress;
  }

  Color _getLeafColor(int layer, int totalLayers) {
    final brightness = layer / totalLayers;
    return Color.lerp(
      AppColors.treeLeaves,
      AppColors.treeLeavesLight,
      brightness,
    )!;
  }

  void _drawShadow(Canvas canvas, double centerX, double groundY) {
    final shadowPaint = Paint()
      ..color = isDark
          ? Colors.black.withOpacity(0.4)
          : Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, groundY + 5),
        width: 100 * growthProgress,
        height: 20 * growthProgress,
      ),
      shadowPaint,
    );
  }

  void _drawFlowers(Canvas canvas, double centerX, double groundY, Size size) {
    // Draw small flower/fruit elements based on hydration
    final random = math.Random(42); // Consistent seed
    final flowerCount = (wellnessData.hydrationLevel * 12).toInt();

    for (int i = 0; i < flowerCount; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * _calculateCanopyRadius(size) * 0.8;
      final canopyY = groundY - _calculateTrunkHeight(size);

      final x = centerX + math.cos(angle) * distance;
      final y = canopyY + math.sin(angle) * distance;

      final flowerPaint = Paint()
        ..color = AppColors.hydrationAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4 * growthProgress, flowerPaint);
    }
  }

  void _drawGlow(Canvas canvas, double centerX, double groundY, Size size) {
    final glowPaint = Paint()
      ..color =
          AppColors.sleepAccent.withOpacity(0.2 * wellnessData.sleepQuality)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        20 * wellnessData.sleepQuality,
      );

    final canopyRadius = _calculateCanopyRadius(size);
    final canopyY = groundY - _calculateTrunkHeight(size);

    canvas.drawCircle(
      Offset(centerX, canopyY),
      canopyRadius * 1.2,
      glowPaint,
    );
  }

  void _drawBarkTexture(Canvas canvas, Path trunkPath) {
    // Add subtle bark texture lines
    final bounds = trunkPath.getBounds();
    final texturePaint = Paint()
      ..color =
          isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = bounds.top; y < bounds.bottom; y += 8) {
      final line = Path()
        ..moveTo(bounds.left + 2, y)
        ..quadraticBezierTo(
          bounds.center.dx,
          y + 2,
          bounds.right - 2,
          y,
        );
      canvas.drawPath(line, texturePaint);
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return stage != oldDelegate.stage ||
        wellnessData != oldDelegate.wellnessData ||
        growthProgress != oldDelegate.growthProgress;
  }
}

// Particle painter for ambient effects
class ParticlePainter extends CustomPainter {
  final double progress;
  final WellnessData wellnessData;
  final bool isDark;

  ParticlePainter({
    required this.progress,
    required this.wellnessData,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Simple particle effects - can be enhanced
    if (wellnessData.totalXP > 0) {
      final paint = Paint()
        ..color = isDark
            ? AppColors.premiumGold.withOpacity(0.5)
            : AppColors.premiumGold.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final random = math.Random(42);
      for (int i = 0; i < 5; i++) {
        final x = size.width * random.nextDouble();
        final y = size.height * random.nextDouble();
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// Helper class for wellness indicator dots
class _WellnessIndicatorDot extends StatefulWidget {
  final Color color;
  final IconData icon;
  final double size;

  const _WellnessIndicatorDot({
    required this.color,
    required this.icon,
    required this.size,
  });

  @override
  State<_WellnessIndicatorDot> createState() => _WellnessIndicatorDotState();
}

class _WellnessIndicatorDotState extends State<_WellnessIndicatorDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: AppDurations.smoothCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final iconColor = isDark
                    ? Theme.of(context).colorScheme.surface
                    : Colors.white;
                return Icon(
                  widget.icon,
                  size: widget.size * 0.6,
                  color: iconColor,
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

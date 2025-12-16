// lib/core/widgets/premium_wellness_ring.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_typography.dart';
import 'package:fitquest/core/constants/app_durations.dart';
import 'package:fitquest/core/services/haptic_service.dart';

/// Production-Grade Wellness Ring with 4 pillar segments
class PremiumWellnessRing extends StatefulWidget {
  final double exerciseProgress;
  final double meditationProgress;
  final double hydrationProgress;
  final double sleepProgress;
  final int level;

  const PremiumWellnessRing({
    super.key,
    required this.exerciseProgress,
    required this.meditationProgress,
    required this.hydrationProgress,
    required this.sleepProgress,
    required this.level,
  });

  @override
  State<PremiumWellnessRing> createState() => _PremiumWellnessRingState();
}

class _PremiumWellnessRingState extends State<PremiumWellnessRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.moderateSlow,
      vsync: this,
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    final overallScore = _calculateOverallScore();

    return GestureDetector(
      onTap: () {
        HapticService.light();
        // Navigate to detailed wellness breakdown
      },
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final onSurfaceVariant =
              Theme.of(context).colorScheme.onSurfaceVariant;

          return Container(
            width: 200,
            height: 200,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main ring with 4 segments
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: WellnessRingPainter(
                          exerciseProgress:
                              widget.exerciseProgress * _controller.value,
                          meditationProgress:
                              widget.meditationProgress * _controller.value,
                          hydrationProgress:
                              widget.hydrationProgress * _controller.value,
                          sleepProgress:
                              widget.sleepProgress * _controller.value,
                          animationProgress: _controller.value,
                          isDark: isDark,
                        ),
                        size: const Size(200, 200),
                      ),
                    );
                  },
                ),

                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Overall score
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: overallScore),
                      duration: AppDurations.moderateSlow,
                      curve: AppDurations.smoothCurve,
                      builder: (context, value, child) {
                        return Text(
                          '${(value * 100).toInt()}%',
                          style: AppTypography.displaySmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primaryGreen.shade700,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    // Status text
                    Text(
                      _getStatusText(overallScore),
                      style: AppTypography.bodySmall.copyWith(
                        color: onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Pillar indicator dots
                ..._buildPillarDots(context),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateOverallScore() {
    return (widget.exerciseProgress +
            widget.meditationProgress +
            widget.hydrationProgress +
            widget.sleepProgress) /
        4.0;
  }

  String _getStatusText(double score) {
    if (score >= 0.9) return 'Excellent';
    if (score >= 0.75) return 'Great';
    if (score >= 0.6) return 'Good';
    if (score >= 0.4) return 'Keep Going';
    return 'Getting Started';
  }

  List<Widget> _buildPillarDots(BuildContext context) {
    final dots = <Widget>[];
    const dotSize = 16.0;

    // Exercise (top-right)
    dots.add(
      Positioned(
        top: 20,
        right: 20,
        child: _PillarDot(
          color: AppColors.exerciseAccent,
          completed: widget.exerciseProgress >= 1.0,
          size: dotSize,
        ),
      ),
    );

    // Meditation (top-left)
    dots.add(
      Positioned(
        top: 20,
        left: 20,
        child: _PillarDot(
          color: AppColors.meditationAccent,
          completed: widget.meditationProgress >= 1.0,
          size: dotSize,
        ),
      ),
    );

    // Hydration (bottom-right)
    dots.add(
      Positioned(
        bottom: 20,
        right: 20,
        child: _PillarDot(
          color: AppColors.hydrationAccent,
          completed: widget.hydrationProgress >= 1.0,
          size: dotSize,
        ),
      ),
    );

    // Sleep (bottom-left)
    dots.add(
      Positioned(
        bottom: 20,
        left: 20,
        child: _PillarDot(
          color: AppColors.sleepAccent,
          completed: widget.sleepProgress >= 1.0,
          size: dotSize,
        ),
      ),
    );

    return dots;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WellnessRingPainter extends CustomPainter {
  final double exerciseProgress;
  final double meditationProgress;
  final double hydrationProgress;
  final double sleepProgress;
  final double animationProgress;
  final bool isDark;

  WellnessRingPainter({
    required this.exerciseProgress,
    required this.meditationProgress,
    required this.hydrationProgress,
    required this.sleepProgress,
    required this.animationProgress,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 12.0;

    // Background ring
    final backgroundPaint = Paint()
      ..color = isDark
          ? AppColors.surfaceVariantDark.withValues(alpha: 0.3)
          : AppColors.surface2.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw each pillar segment
    _drawSegment(
      canvas,
      center,
      radius,
      strokeWidth,
      0,
      exerciseProgress,
      AppColors.exerciseAccent,
    );

    _drawSegment(
      canvas,
      center,
      radius,
      strokeWidth,
      0.25,
      meditationProgress,
      AppColors.meditationAccent,
    );

    _drawSegment(
      canvas,
      center,
      radius,
      strokeWidth,
      0.5,
      hydrationProgress,
      AppColors.hydrationAccent,
    );

    _drawSegment(
      canvas,
      center,
      radius,
      strokeWidth,
      0.75,
      sleepProgress,
      AppColors.sleepAccent,
    );
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    double startFraction,
    double progress,
    Color color,
  ) {
    if (progress <= 0) return;

    final startAngle = -math.pi / 2 + (startFraction * 2 * math.pi);
    final sweepAngle = (math.pi / 2) * progress * 0.95; // 95% of quarter circle

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );

    canvas.drawPath(path, paint);

    // Add glow effect at end of segment
    if (progress >= 1.0) {
      final endAngle = startAngle + sweepAngle;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(endPoint, strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(WellnessRingPainter oldDelegate) {
    return exerciseProgress != oldDelegate.exerciseProgress ||
        meditationProgress != oldDelegate.meditationProgress ||
        hydrationProgress != oldDelegate.hydrationProgress ||
        sleepProgress != oldDelegate.sleepProgress ||
        animationProgress != oldDelegate.animationProgress;
  }
}

class _PillarDot extends StatelessWidget {
  final Color color;
  final bool completed;
  final double size;

  const _PillarDot({
    required this.color,
    required this.completed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? Theme.of(context).colorScheme.surface : Colors.white;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: completed ? 1.0 : 0.5),
      duration: AppDurations.moderate,
      curve: AppDurations.standardCurve,
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: completed ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: completed
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: completed
              ? Icon(
                  Icons.check,
                  color: borderColor,
                  size: 10,
                )
              : null,
        );
      },
    );
  }
}

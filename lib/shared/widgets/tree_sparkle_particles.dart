// lib/shared/widgets/tree_sparkle_particles.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fitquest/core/constants/app_colors.dart';

/// Sparkle particle system for tree enhancement
/// Phase 3: Sparkle particles around tree
class TreeSparkleParticles extends StatefulWidget {
  final int particleCount;
  final Color sparkleColor;
  final double treeSize;
  final bool active;

  const TreeSparkleParticles({
    super.key,
    this.particleCount = 8,
    this.sparkleColor = const Color(0xFFF5C518), // XP gold color
    required this.treeSize,
    this.active = true,
  });

  @override
  State<TreeSparkleParticles> createState() => _TreeSparkleParticlesState();
}

class _TreeSparkleParticlesState extends State<TreeSparkleParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<SparkleParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => SparkleParticle.random(widget.treeSize),
    );

    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    if (!widget.active) return;
    setState(() {
      for (var particle in _particles) {
        particle.update(_controller.value);
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
    if (!widget.active) return const SizedBox.shrink();

    return CustomPaint(
      size: Size(widget.treeSize * 1.5, widget.treeSize * 1.5),
      painter: _SparkleParticlesPainter(
        particles: _particles,
        sparkleColor: widget.sparkleColor,
      ),
    );
  }
}

class SparkleParticle {
  Offset position;
  double size;
  double opacity;
  double velocityY;
  double rotation;
  double rotationSpeed;
  Color color;
  double baseY;

  SparkleParticle({
    required this.position,
    required this.size,
    required this.opacity,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.baseY,
  });

  factory SparkleParticle.random(double treeSize) {
    final random = math.Random();
    final angle = random.nextDouble() * 2 * math.pi;
    final distance = treeSize * 0.4 + random.nextDouble() * treeSize * 0.3;
    final centerX = treeSize * 0.75;
    final centerY = treeSize * 0.5;

    return SparkleParticle(
      position: Offset(
        centerX + math.cos(angle) * distance,
        centerY + math.sin(angle) * distance,
      ),
      size: 4 + random.nextDouble() * 4,
      opacity: 0.3 + random.nextDouble() * 0.7,
      velocityY: -0.5 - random.nextDouble() * 0.5,
      rotation: random.nextDouble() * 2 * math.pi,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.1,
      color: AppColors.xp,
      baseY: centerY + math.sin(angle) * distance,
    );
  }

  void update(double time) {
    // Floating motion
    position = Offset(
      position.dx,
      baseY + math.sin(time * 2 * math.pi + position.dx * 0.01) * 10,
    );

    // Rotation
    rotation += rotationSpeed;

    // Opacity pulse
    opacity =
        0.3 + (math.sin(time * 2 * math.pi + position.dx * 0.1).abs() * 0.7);
  }
}

class _SparkleParticlesPainter extends CustomPainter {
  final List<SparkleParticle> particles;
  final Color sparkleColor;

  _SparkleParticlesPainter({
    required this.particles,
    required this.sparkleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      // Draw star shape
      final path = Path();
      final center = particle.position;
      final radius = particle.size;

      for (int i = 0; i < 5; i++) {
        final angle = (i * 4 * math.pi / 5) - math.pi / 2;
        final x = center.dx + math.cos(angle + particle.rotation) * radius;
        final y = center.dy + math.sin(angle + particle.rotation) * radius;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);

      // Add glow
      final glowPaint = Paint()
        ..color = sparkleColor.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_SparkleParticlesPainter oldDelegate) => true;
}

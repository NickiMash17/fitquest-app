// lib/shared/widgets/particle_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fitquest/core/constants/app_colors.dart';

/// Animated particle background effect
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color? particleColor;
  final double speed;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor,
    this.speed = 1.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => _Particle.random(),
    );

    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.update(widget.speed);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.particleColor ??
        AppColors.primaryGreen.withValues(alpha: 0.1);

    return Stack(
      children: [
        widget.child,
        // Particles layer
        ..._particles.map((particle) {
          return Positioned(
            left: particle.x,
            top: particle.y,
            child: Opacity(
              opacity: particle.opacity,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: particle.size,
                      spreadRadius: particle.size / 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });

  factory _Particle.random() {
    final random = math.Random();
    return _Particle(
      x: random.nextDouble() * 400,
      y: random.nextDouble() * 800,
      vx: (random.nextDouble() - 0.5) * 0.5,
      vy: (random.nextDouble() - 0.5) * 0.5,
      size: 2 + random.nextDouble() * 4,
      opacity: 0.1 + random.nextDouble() * 0.3,
    );
  }

  void update(double speed) {
    x += vx * speed;
    y += vy * speed;

    // Wrap around edges
    if (x < 0) x = 400;
    if (x > 400) x = 0;
    if (y < 0) y = 800;
    if (y > 800) y = 0;
  }
}


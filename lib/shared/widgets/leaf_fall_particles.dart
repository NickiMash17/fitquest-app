// lib/shared/widgets/leaf_fall_particles.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fitquest/core/constants/app_colors.dart';

/// Falling leaf particles when tree is shaken
/// Phase 3: Leaf fall particles
class LeafFallParticles extends StatefulWidget {
  final int leafCount;
  final Color leafColor;
  final Duration duration;
  final Offset startPosition;
  final VoidCallback? onComplete;

  const LeafFallParticles({
    super.key,
    this.leafCount = 5,
    this.leafColor = const Color(0xFF29A34D), // Tree leaves color
    this.duration = const Duration(seconds: 2),
    required this.startPosition,
    this.onComplete,
  });

  @override
  State<LeafFallParticles> createState() => _LeafFallParticlesState();

  /// Trigger leaf fall animation
  static void show(
    BuildContext context,
    Offset startPosition, {
    int leafCount = 5,
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => LeafFallParticles(
        leafCount: leafCount,
        startPosition: startPosition,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _LeafFallParticlesState extends State<LeafFallParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<FallingLeaf> _leaves;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _leaves = List.generate(
      widget.leafCount,
      (index) => FallingLeaf.random(
        startPosition: widget.startPosition,
        delay: index * 0.1,
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
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
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _LeafFallPainter(
          leaves: _leaves,
          animationValue: _controller.value,
          leafColor: widget.leafColor,
        ),
      ),
    );
  }
}

class FallingLeaf {
  Offset startPosition;
  Offset endPosition;
  double size;
  double rotation;
  double rotationSpeed;
  double delay;
  Color color;

  FallingLeaf({
    required this.startPosition,
    required this.endPosition,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.delay,
    required this.color,
  });

  factory FallingLeaf.random({
    required Offset startPosition,
    double delay = 0.0,
  }) {
    final random = math.Random();
    return FallingLeaf(
      startPosition: startPosition,
      endPosition: Offset(
        startPosition.dx + (random.nextDouble() - 0.5) * 100,
        startPosition.dy + 200 + random.nextDouble() * 100,
      ),
      size: 8 + random.nextDouble() * 8,
      rotation: random.nextDouble() * 2 * math.pi,
      rotationSpeed: (random.nextDouble() - 0.5) * 2,
      delay: delay,
      color: AppColors.treeLeaves,
    );
  }

  Offset getPosition(double animationValue) {
    if (animationValue < delay) {
      return startPosition;
    }
    final t = ((animationValue - delay) / (1 - delay)).clamp(0.0, 1.0);
    final curve = Curves.easeInOut.transform(t);
    return Offset.lerp(startPosition, endPosition, curve)!;
  }

  double getRotation(double animationValue) {
    if (animationValue < delay) return rotation;
    final t = ((animationValue - delay) / (1 - delay)).clamp(0.0, 1.0);
    return rotation + rotationSpeed * t * 2 * math.pi;
  }

  double getOpacity(double animationValue) {
    if (animationValue < delay) return 0.0;
    final t = ((animationValue - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (t > 0.8) {
      return (1 - (t - 0.8) / 0.2);
    }
    return 1.0;
  }
}

class _LeafFallPainter extends CustomPainter {
  final List<FallingLeaf> leaves;
  final double animationValue;
  final Color leafColor;

  _LeafFallPainter({
    required this.leaves,
    required this.animationValue,
    required this.leafColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var leaf in leaves) {
      final position = leaf.getPosition(animationValue);
      final rotation = leaf.getRotation(animationValue);
      final opacity = leaf.getOpacity(animationValue);

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = leaf.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      // Draw leaf shape (simple ellipse)
      final leafRect = Rect.fromCenter(
        center: Offset.zero,
        width: leaf.size,
        height: leaf.size * 0.6,
      );
      canvas.drawOval(leafRect, paint);

      // Add leaf vein
      final veinPaint = Paint()
        ..color = leaf.color.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(0, -leaf.size * 0.3),
        Offset(0, leaf.size * 0.3),
        veinPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeafFallPainter oldDelegate) => true;
}

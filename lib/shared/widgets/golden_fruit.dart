import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Golden fruit widget that appears on majestic trees (level 36+)
class GoldenFruit extends StatefulWidget {
  final double size;
  final bool animated;

  const GoldenFruit({
    super.key,
    this.size = 30.0,
    this.animated = true,
  });

  @override
  State<GoldenFruit> createState() => _GoldenFruitState();
}

class _GoldenFruitState extends State<GoldenFruit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat(reverse: true);

      _bounceAnimation = Tween<double>(
        begin: 0.0,
        end: 8.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _glowAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.5),
          weight: 1,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animated) {
      return _buildFruit();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.xpGold.withValues(
                    alpha: _glowAnimation.value * 0.6,
                  ),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: _buildFruit(),
          ),
        );
      },
    );
  }

  Widget _buildFruit() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: GoldenFruitPainter(),
    );
  }
}

class GoldenFruitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Main fruit body (golden gradient)
    final fruitPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFCD34D), // Light gold
          Color(0xFFFBBF24), // Gold
          Color(0xFFF59E0B), // Dark gold
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, fruitPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;
    final stemPath = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy - radius)
      ..lineTo(center.dx + radius * 0.2, center.dy - radius)
      ..lineTo(center.dx + radius * 0.1, center.dy - radius * 1.2)
      ..lineTo(center.dx - radius * 0.1, center.dy - radius * 1.2)
      ..close();
    canvas.drawPath(stemPath, stemPaint);

    // Leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(center.dx, center.dy - radius * 1.2)
      ..quadraticBezierTo(
        center.dx + radius * 0.3,
        center.dy - radius * 1.3,
        center.dx + radius * 0.2,
        center.dy - radius * 1.1,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 1.2,
        center.dx,
        center.dy - radius * 1.2,
      );
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


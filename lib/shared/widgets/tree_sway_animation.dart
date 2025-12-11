import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget that applies a continuous swaying animation to a tree
class TreeSwayAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double swayAmount;

  const TreeSwayAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
    this.swayAmount = 0.08, // 8% sway - more visible
  });

  @override
  State<TreeSwayAnimation> createState() => _TreeSwayAnimationState();
}

class _TreeSwayAnimationState extends State<TreeSwayAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _swayAnimation = Tween<double>(
      begin: -widget.swayAmount,
      end: widget.swayAmount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _swayAnimation.value,
          alignment: Alignment.bottomCenter,
          child: widget.child,
        );
      },
    );
  }
}

/// Floating leaf particle widget
class FloatingLeaf extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Offset startPosition;
  final Offset endPosition;

  const FloatingLeaf({
    super.key,
    this.size = 20.0,
    this.color = const Color(0xFF4ADE80),
    this.duration = const Duration(seconds: 8),
    required this.startPosition,
    required this.endPosition,
  });

  @override
  State<FloatingLeaf> createState() => _FloatingLeafState();
}

class _FloatingLeafState extends State<FloatingLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 0.6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 0.2,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: LeafPainter(color: widget.color),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for leaf shape
class LeafPainter extends CustomPainter {
  final Color color;

  LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.4,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width / 2,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Container for multiple floating leaves
class FloatingLeavesBackground extends StatelessWidget {
  final int leafCount;
  final Widget child;

  const FloatingLeavesBackground({
    super.key,
    this.leafCount = 8,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ...List.generate(leafCount, (index) {
          final screenSize = MediaQuery.of(context).size;
          return FloatingLeaf(
            startPosition: Offset(
              (index * 50.0) % screenSize.width,
              screenSize.height + 50,
            ),
            endPosition: Offset(
              (index * 50.0) % screenSize.width,
              -50,
            ),
            duration: Duration(seconds: 8 + (index % 3)),
            size: 15.0 + (index % 3) * 5.0,
            color: const Color(0xFF4ADE80).withValues(
              alpha: 0.3 + (index % 3) * 0.2,
            ),
          );
        }),
      ],
    );
  }
}

// lib/shared/widgets/tilt_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Card with tilt effect on hover (for web/desktop)
/// Phase 2: Card hover tilt effects
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final VoidCallback? onTap;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 10.0,
    this.onTap,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(PointerEvent event, Size size) {
    if (!_controller.isAnimating) {
      _controller.forward();
    }
    setState(() {
      final localPosition = event.localPosition;
      if (size.width > 0 && size.height > 0) {
        _tiltX = ((localPosition.dx / size.width) - 0.5) * widget.maxTilt;
        _tiltY = ((localPosition.dy / size.height) - 0.5) * widget.maxTilt;
      }
    });
  }

  void _handleExit() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MouseRegion(
            onEnter: (event) {
              _handleHover(event, Size(constraints.maxWidth, constraints.maxHeight));
            },
            onHover: (event) {
              _handleHover(event, Size(constraints.maxWidth, constraints.maxHeight));
            },
            onExit: (_) => _handleExit(),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateX(_tiltY * math.pi / 180) // convert to radians
                    ..rotateY(_tiltX * math.pi / 180),
                  alignment: Alignment.center,
                  child: widget.child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// lib/shared/widgets/enhanced_tree_sway.dart
import 'package:flutter/material.dart';

/// Enhanced tree sway animation with wind strength variation
/// Phase 3: Enhanced tree sway with wind strength
class EnhancedTreeSway extends StatefulWidget {
  final Widget child;
  final Duration baseDuration;
  final double baseSwayAmount;
  final double windStrength; // 0.0 - 1.0 (0 = calm, 1 = strong wind)

  const EnhancedTreeSway({
    super.key,
    required this.child,
    this.baseDuration = const Duration(seconds: 4),
    this.baseSwayAmount = 0.08,
    this.windStrength = 0.5,
  });

  @override
  State<EnhancedTreeSway> createState() => _EnhancedTreeSwayState();
}

class _EnhancedTreeSwayState extends State<EnhancedTreeSway>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;
  late Animation<double> _windVariationAnimation;

  @override
  void initState() {
    super.initState();

    // Base sway controller
    _controller = AnimationController(
      duration: widget.baseDuration,
      vsync: this,
    )..repeat();

    // Calculate actual sway amount based on wind strength
    final actualSway = widget.baseSwayAmount * (0.5 + widget.windStrength);

    _swayAnimation = Tween<double>(
      begin: -actualSway,
      end: actualSway,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Wind variation (random gusts)
    _windVariationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: widget.windStrength * 0.3),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.windStrength * 0.3, end: 0.0),
        weight: 0.7,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(EnhancedTreeSway oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windStrength != widget.windStrength ||
        oldWidget.baseSwayAmount != widget.baseSwayAmount) {
      final actualSway = widget.baseSwayAmount * (0.5 + widget.windStrength);
      _swayAnimation = Tween<double>(
        begin: -actualSway,
        end: actualSway,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }
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
        // Combine base sway with wind variation
        final totalSway = _swayAnimation.value + _windVariationAnimation.value;

        return Transform.rotate(
          angle: totalSway,
          alignment: Alignment.bottomCenter,
          child: widget.child,
        );
      },
    );
  }
}

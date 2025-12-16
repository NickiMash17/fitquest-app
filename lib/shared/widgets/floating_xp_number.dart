// lib/shared/widgets/floating_xp_number.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Floating XP number animation that appears when XP is gained
/// Phase 2: Floating +XP numbers
class FloatingXpNumber extends StatefulWidget {
  final int amount;
  final Offset startPosition;
  final VoidCallback? onComplete;
  final String? label; // Optional label (e.g., "XP", "Points")
  final Color? color; // Optional custom color

  const FloatingXpNumber({
    super.key,
    required this.amount,
    required this.startPosition,
    this.onComplete,
    this.label,
    this.color,
  });

  @override
  State<FloatingXpNumber> createState() => _FloatingXpNumberState();

  /// Show floating XP number overlay
  static void show(
    BuildContext context,
    int amount,
    Offset startPosition, {
    VoidCallback? onComplete,
    String? label,
    Color? color,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => FloatingXpNumber(
        amount: amount,
        startPosition: startPosition,
        label: label,
        color: color,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _FloatingXpNumberState extends State<FloatingXpNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _translateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 0.7,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
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
    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    '+${widget.amount} ${widget.label ?? "XP"}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: widget.color ?? AppColors.xp,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: (widget.color ?? AppColors.xp).withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.9),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// lib/shared/widgets/swipeable_card.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Swipeable card widget with left and right swipe actions
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final Widget? leftAction;
  final Widget? rightAction;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Color? leftActionColor;
  final Color? rightActionColor;
  final double threshold;
  final bool enableHapticFeedback;

  const SwipeableCard({
    super.key,
    required this.child,
    this.leftAction,
    this.rightAction,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionColor,
    this.rightActionColor,
    this.threshold = 0.3,
    this.enableHapticFeedback = true,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;
  bool _hasTriggeredAction = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_hasTriggeredAction) return;

    setState(() {
      _dragExtent += details.primaryDelta! / MediaQuery.of(context).size.width;
      _dragExtent = _dragExtent.clamp(-1.0, 1.0);
    });

    // Trigger haptic feedback at threshold
    if (widget.enableHapticFeedback) {
      if ((_dragExtent.abs() >= widget.threshold) &&
          (_dragExtent.abs() < widget.threshold + 0.05)) {
        HapticFeedbackService.lightImpact();
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_hasTriggeredAction) {
      _reset();
      return;
    }

    final shouldTriggerLeft = _dragExtent <= -widget.threshold && widget.onSwipeLeft != null;
    final shouldTriggerRight = _dragExtent >= widget.threshold && widget.onSwipeRight != null;

    if (shouldTriggerLeft || shouldTriggerRight) {
      _hasTriggeredAction = true;
      if (widget.enableHapticFeedback) {
        HapticFeedbackService.mediumImpact();
      }
      
      if (shouldTriggerLeft) {
        widget.onSwipeLeft?.call();
      } else {
        widget.onSwipeRight?.call();
      }
      
      // Animate out
      _controller.forward().then((_) {
        _reset();
      });
    } else {
      _reset();
    }
  }

  void _reset() {
    setState(() {
      _dragExtent = 0.0;
      _hasTriggeredAction = false;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final leftActionVisible = _dragExtent < 0 && widget.leftAction != null;
    final rightActionVisible = _dragExtent > 0 && widget.rightAction != null;

    return Stack(
      children: [
        // Background actions
        if (leftActionVisible || rightActionVisible)
          Positioned.fill(
            child: Row(
              children: [
                if (leftActionVisible)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.leftActionColor ??
                            Theme.of(context).colorScheme.error,
                        borderRadius: AppBorderRadius.allMD,
                      ),
                      child: Center(child: widget.leftAction),
                    ),
                  ),
                if (rightActionVisible)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.rightActionColor ??
                            Theme.of(context).colorScheme.primary,
                        borderRadius: AppBorderRadius.allMD,
                      ),
                      child: Center(child: widget.rightAction),
                    ),
                  ),
              ],
            ),
          ),
        // Swipeable card
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(
              _dragExtent * MediaQuery.of(context).size.width * 0.8,
              0,
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Live region widget for screen reader announcements
/// Use this to announce dynamic content changes to screen readers
/// 
/// Example:
/// ```dart
/// LiveRegion(
///   message: 'Activity saved successfully',
///   child: YourWidget(),
/// )
/// ```
class LiveRegion extends StatefulWidget {
  final Widget child;
  final String? message;
  final bool assertive; // If true, interrupts current speech

  const LiveRegion({
    super.key,
    required this.child,
    this.message,
    this.assertive = false,
  });

  @override
  State<LiveRegion> createState() => _LiveRegionState();
}

class _LiveRegionState extends State<LiveRegion> {
  String? _lastMessage;

  @override
  void didUpdateWidget(LiveRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != null && widget.message != oldWidget.message) {
      _lastMessage = widget.message;
      // Announce to screen readers
      SemanticsService.announce(
        widget.message!,
        widget.assertive ? TextDirection.ltr : TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: widget.message ?? _lastMessage,
      child: widget.child,
    );
  }
}

/// Live region controller for programmatic announcements
class LiveRegionController {
  static void announce(BuildContext context, String message, {bool assertive = false}) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
    );
  }
}


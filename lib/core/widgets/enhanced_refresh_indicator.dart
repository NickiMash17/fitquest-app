// lib/core/widgets/enhanced_refresh_indicator.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/services/haptic_service.dart';

/// Enhanced refresh indicator with haptic feedback
class EnhancedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticService.light();
        await onRefresh();
      },
      color: color ?? AppColors.primaryGreen,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      strokeWidth: strokeWidth,
      displacement: 40,
      edgeOffset: 20,
      child: child,
    );
  }
}


// lib/shared/widgets/premium_refresh_indicator.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Premium refresh indicator with custom styling
class PremiumRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PremiumRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.white,
      backgroundColor: color ?? AppColors.primaryGreen,
      strokeWidth: 3,
      displacement: 40,
      child: child,
    );
  }
}


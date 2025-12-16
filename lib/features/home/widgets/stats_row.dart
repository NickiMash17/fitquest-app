// lib/features/home/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/widgets/enhanced_stat_card.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Enhanced stats row with staggered animations
class StatsRow extends StatelessWidget {
  final int points;
  final int streak;
  final int level;

  const StatsRow({
    super.key,
    required this.points,
    required this.streak,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: EnhancedStatCard(
            icon: Icons.star_rounded,
            value: points,
            label: 'Points',
            gradient: AppColors.premiumGoldGradient,
            iconColor: AppColors.premiumGold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EnhancedStatCard(
            icon: Icons.local_fire_department_rounded,
            value: streak,
            label: 'Day Streak',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
            ),
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EnhancedStatCard(
            icon: Icons.emoji_events_rounded,
            value: level,
            label: 'Level',
            gradient: AppColors.blueGradient,
            iconColor: AppColors.accentBlue,
          ),
        ),
      ],
    );
  }
}

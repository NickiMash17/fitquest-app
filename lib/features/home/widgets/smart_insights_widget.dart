// lib/features/home/widgets/smart_insights_widget.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/models/user_model.dart';

class SmartInsightsWidget extends StatelessWidget {
  final UserModel user;

  const SmartInsightsWidget({
    super.key,
    required this.user,
  });

  String _getInsight() {
    final streak = user.currentStreak;
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 10) {
      if (streak == 0) {
        return 'Start your day right! Log your first activity to begin your wellness journey.';
      }
      return 'Morning is perfect for a quick workout or meditation to energize your day!';
    } else if (hour >= 10 && hour < 14) {
      return 'Midday break? A 10-minute walk or hydration check keeps you refreshed!';
    } else if (hour >= 14 && hour < 18) {
      return 'Afternoon energy dip? A quick activity can boost your focus and mood!';
    } else if (hour >= 18 && hour < 22) {
      return 'Evening is great for reflection. Log your activities and prepare for tomorrow!';
    } else {
      return 'Time to wind down. Track your sleep for better recovery and wellness!';
    }
  }

  String _getHealthTip() {
    final health = user.plantHealth;
    final streak = user.currentStreak;

    if (health < 50) {
      return 'Your plant needs attention! Log activities today to restore its health.';
    } else if (health < 75) {
      return 'Your plant is doing well! Keep up the consistency to see it thrive.';
    } else if (streak >= 7) {
      return 'Amazing $streak-day streak! Your dedication is inspiring your plant to grow!';
    } else if (streak >= 3) {
      return 'Great momentum! Your $streak-day streak is helping your plant flourish!';
    } else {
      return 'Every activity counts! Your plant grows stronger with each logged session.';
    }
  }

  IconData _getInsightIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 18) {
      return Icons.light_mode_rounded;
    } else {
      return Icons.nightlight_round_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insight = _getInsight();
    final tip = _getHealthTip();
    final icon = _getInsightIcon();

    return PremiumCard(
      padding: const EdgeInsets.all(20.0),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPurple.withValues(alpha: 0.2),
                      AppColors.accentBlue.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: AppBorderRadius.allMD,
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Smart Insight',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightest.withValues(alpha: 0.5),
              borderRadius: AppBorderRadius.allMD,
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.accentOrange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tip,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

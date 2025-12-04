import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/features/achievements/widgets/achievement_card.dart';
import 'package:fitquest/shared/models/achievement_model.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual achievements from BLoC/Repository
    final achievements = _getDefaultAchievements();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            PremiumCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${achievements.where((a) => a.unlocked).length}',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlocked',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Achievements list
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'All Achievements',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...achievements.map(
              (achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementCard(achievement: achievement),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AchievementModel> _getDefaultAchievements() {
    return [
      const AchievementModel(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        targetValue: 7,
        icon: '🔥',
        currentProgress: 0,
        unlocked: false,
        xpReward: 100,
      ),
      const AchievementModel(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 30,
        icon: '🔥',
        currentProgress: 0,
        unlocked: false,
        xpReward: 500,
      ),
      const AchievementModel(
        id: 'xp_1000',
        title: 'XP Collector',
        description: 'Earn 1,000 XP',
        type: AchievementType.xp,
        rarity: AchievementRarity.common,
        targetValue: 1000,
        icon: '⭐',
        currentProgress: 0,
        unlocked: false,
        xpReward: 200,
      ),
      const AchievementModel(
        id: 'activities_100',
        title: 'Century Club',
        description: 'Complete 100 activities',
        type: AchievementType.activities,
        rarity: AchievementRarity.rare,
        targetValue: 100,
        icon: '🏃',
        currentProgress: 0,
        unlocked: false,
        xpReward: 300,
      ),
      const AchievementModel(
        id: 'level_10',
        title: 'Level Up',
        description: 'Reach level 10',
        type: AchievementType.level,
        rarity: AchievementRarity.epic,
        targetValue: 10,
        icon: '🎖️',
        currentProgress: 0,
        unlocked: false,
        xpReward: 500,
      ),
    ];
  }
}

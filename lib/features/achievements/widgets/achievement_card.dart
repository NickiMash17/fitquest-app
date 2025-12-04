import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/models/achievement_model.dart';
import 'package:confetti/confetti.dart';

class AchievementCard extends StatefulWidget {
  final AchievementModel achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.achievement.targetValue > 0
        ? (widget.achievement.currentProgress / widget.achievement.targetValue)
            .clamp(0.0, 1.0)
        : 0.0;
    final isUnlocked = widget.achievement.unlocked;

    return Stack(
      children: [
        PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Achievement icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _getRarityGradient(widget.achievement.rarity),
                      borderRadius: AppBorderRadius.allMD,
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color:
                                    _getRarityColor(widget.achievement.rarity)
                                        .withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getAchievementIcon(widget.achievement.type),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.achievement.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ),
                            if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: AppBorderRadius.allSM,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.achievement.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              if (!isUnlocked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          '${widget.achievement.currentProgress}/${widget.achievement.targetValue}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppBorderRadius.allSM,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRarityColor(widget.achievement.rarity),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppBorderRadius.allSM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unlocked! +${widget.achievement.xpReward} XP',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Confetti effect
        if (isUnlocked)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
      ],
    );
  }

  Gradient _getRarityGradient(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade600],
        );
      case AchievementRarity.rare:
        return AppColors.blueGradient;
      case AchievementRarity.epic:
        return AppColors.purpleGradient;
      case AchievementRarity.legendary:
        return LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        );
    }
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return AppColors.accentBlue;
      case AchievementRarity.epic:
        return AppColors.accentPurple;
      case AchievementRarity.legendary:
        return Colors.amber;
    }
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department_rounded;
      case AchievementType.xp:
        return Icons.star_rounded;
      case AchievementType.activities:
        return Icons.directions_run_rounded;
      case AchievementType.level:
        return Icons.emoji_events_rounded;
      case AchievementType.special:
        return Icons.diamond_rounded;
    }
  }
}

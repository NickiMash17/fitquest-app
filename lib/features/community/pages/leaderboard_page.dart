import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/repositories/leaderboard_repository.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/models/leaderboard_entry.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/premium_avatar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _leaderboardRepository = getIt<LeaderboardRepository>();
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final entries = await _leaderboardRepository.getLeaderboard();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load leaderboard')),
        );
      }
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver - better contrast
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.accentBlue;
  }

  Gradient? _getRankGradient(int rank) {
    if (rank == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
      );
    }
    if (rank == 2) {
      return const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFF9E9E9E)],
      );
    }
    if (rank == 3) {
      return const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
      );
    }
    return null;
  }

  IconData _getRankIcon(int rank) {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.workspace_premium;
    if (rank == 3) return Icons.military_tech;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: ListView.builder(
                padding: AppSpacing.screenPadding,
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final rankGradient = _getRankGradient(entry.rank);

                  // Create user model for avatar
                  final userModel = UserModel(
                    id: entry.userId,
                    email: '',
                    displayName: entry.displayName,
                    photoUrl: entry.photoUrl,
                    totalXp: entry.totalXp,
                    currentLevel: entry.currentLevel,
                    currentStreak: entry.currentStreak,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(20),
                      showShadow: true,
                      backgroundColor: entry.rank <= 3
                          ? _getRankColor(entry.rank)
                              .withValues(alpha: 0.05)
                          : null,
                      border: entry.rank <= 3
                          ? Border.all(
                              color: _getRankColor(entry.rank)
                                  .withValues(alpha: 0.3),
                              width: 2,
                            )
                          : null,
                      child: Row(
                        children: [
                          // Rank badge for top 3
                          if (entry.rank <= 3)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: rankGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getRankColor(entry.rank)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getRankIcon(entry.rank),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          if (entry.rank <= 3) const SizedBox(width: 16),
                          // Premium Avatar
                          PremiumAvatar(
                            user: userModel,
                            size: 56,
                            showBadge: true,
                            showLevelRing: true,
                          ),
                          const SizedBox(width: 16),
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        entry.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (entry.rank <= 3) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: rankGradient,
                                          borderRadius:
                                              AppBorderRadius.allSM,
                                        ),
                                        child: Text(
                                          '#${entry.rank}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppBorderRadius.allSM,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.emoji_events_rounded,
                                            size: 14,
                                            color: AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Lvl ${entry.currentLevel}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentOrange
                                            .withValues(alpha: 0.1),
                                        borderRadius: AppBorderRadius.allSM,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 14,
                                            color: AppColors.accentOrange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${entry.currentStreak}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: AppColors.accentOrange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // XP badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppBorderRadius.allMD,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${entry.totalXp}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                Text(
                                  'XP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

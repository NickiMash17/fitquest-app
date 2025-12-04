import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/repositories/leaderboard_repository.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/models/leaderboard_entry.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';

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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(16),
                      showShadow: true,
                      child: Row(
                        children: [
                          // Rank icon with gradient
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: rankGradient,
                              color: rankGradient == null
                                  ? _getRankColor(entry.rank)
                                  : null,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getRankColor(entry.rank)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getRankIcon(entry.rank),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.displayName,
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Level ${entry.currentLevel}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${entry.currentStreak} day streak',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // XP and rank
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: AppBorderRadius.allSM,
                                ),
                                child: Text(
                                  '${entry.totalXp} XP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '#${entry.rank}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/premium_avatar.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/authentication/bloc/auth_state.dart';
import 'package:fitquest/shared/models/activity_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              AppRouter.navigate(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  // Enhanced Profile header
                  PremiumCard(
                    padding: const EdgeInsets.all(32.0),
                    gradient: AppColors.primaryGradient,
                    child: Column(
                      children: [
                        AnimatedPremiumAvatar(
                          user: user,
                          size: 100,
                          showBadge: true,
                          showLevelRing: true,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user.displayName ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.email_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Enhanced Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total XP',
                          user.totalXp.toString(),
                          Icons.star_rounded,
                          AppColors.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Level',
                          user.currentLevel.toString(),
                          Icons.emoji_events_rounded,
                          AppColors.accentGradient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Current Streak',
                          '${user.currentStreak} days',
                          Icons.local_fire_department_rounded,
                          const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Longest Streak',
                          '${user.longestStreak} days',
                          Icons.whatshot_rounded,
                          const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE53935), Color(0xFFC62828)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Menu items
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistics',
                    subtitle: 'View your progress',
                    onTap: () {
                      AppRouter.navigate(context, AppRouter.statistics);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.workspace_premium_rounded,
                    title: 'Achievements',
                    subtitle: '${user.unlockedBadges.length} unlocked',
                    onTap: () {
                      AppRouter.navigate(context, AppRouter.achievements);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.flag_rounded,
                    title: 'Goals',
                    subtitle: 'Set and track goals',
                    onTap: () {
                      AppRouter.navigate(context, AppRouter.goals);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: 'Calendar',
                    subtitle: 'View activity history',
                    onTap: () {
                      // TODO: Get activities from BLoC
                      AppRouter.navigate(
                        context,
                        AppRouter.calendar,
                        arguments: <ActivityModel>[],
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.leaderboard_outlined,
                    title: 'Leaderboard',
                    subtitle: 'See your ranking',
                    onTap: () {
                      AppRouter.navigate(context, AppRouter.leaderboard);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      AppRouter.navigate(context, AppRouter.settings);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sign out button
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested());
                      AppRouter.navigateAndRemoveUntil(
                        context,
                        AppRouter.login,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return PremiumCard(
      padding: const EdgeInsets.all(20.0),
      gradient: gradient,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.allMD,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

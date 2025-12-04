// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/features/home/bloc/home_bloc.dart';
import 'package:fitquest/features/home/bloc/home_event.dart';
import 'package:fitquest/features/home/bloc/home_state.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/repositories/challenge_repository.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/features/home/widgets/welcome_header.dart';
import 'package:fitquest/features/home/widgets/plant_companion_card.dart';
import 'package:fitquest/features/home/widgets/stats_row.dart';
import 'package:fitquest/features/home/widgets/quick_actions_section.dart';
import 'package:fitquest/features/home/widgets/daily_challenge_card.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/shared/widgets/skeleton_loader.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          final bloc = getIt<HomeBloc>();
          bloc.add(const HomeDataLoadRequested());
          return bloc;
        } catch (e) {
          debugPrint('Error creating HomeBloc: $e');
          // Fallback: create manually
          return HomeBloc(
            getIt<UserRepository>(),
            getIt<ChallengeRepository>(),
            getIt<ActivityRepository>(),
            getIt<FirebaseAuth>(),
          )..add(const HomeDataLoadRequested());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              // Handle initial state - trigger load
              if (state is HomeInitial) {
                // Trigger load if not already loading
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<HomeBloc>().add(const HomeDataLoadRequested());
                });
                return _buildSkeletonLoader(context);
              }

              if (state is HomeLoading) {
                return _buildSkeletonLoader(context);
              }

              if (state is HomeError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to Load',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<HomeBloc>()
                                .add(const HomeDataLoadRequested());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () async {
                            // Sign out and go back to login
                            final authBloc = context.read<AuthBloc>();
                            authBloc.add(const AuthSignOutRequested());
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRouter.login,
                                (route) => false,
                              );
                            }
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is HomeLoaded) {
                try {
                  final user = state.user;
                  final xpCalculator = getIt<XpCalculatorService>();
                  final evolutionStage =
                      xpCalculator.calculateEvolutionStage(user.plantCurrentXp);
                  final stageName =
                      xpCalculator.getEvolutionStageName(evolutionStage);
                  final nextLevelXp =
                      xpCalculator.xpRequiredForNextLevel(user.currentLevel);
                  final challengeProgress = state.dailyChallenge != null &&
                          state.dailyChallenge!.targetValue > 0
                      ? (state.todayXp /
                              (state.dailyChallenge!.targetValue * 5))
                          .clamp(0.0, 1.0)
                      : 0.0;

                  return CustomScrollView(
                    slivers: [
                      // Enhanced App Bar with Welcome Header
                      SliverAppBar(
                        floating: true,
                        pinned: false,
                        elevation: 0,
                        backgroundColor: AppColors.primaryGreen,
                        expandedHeight: 160,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 16, 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: WelcomeHeader(user: user),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.notifications_outlined,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              // TODO: Navigate to notifications
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Main content
                      SliverToBoxAdapter(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<HomeBloc>()
                                .add(const HomeDataRefreshRequested());
                          },
                          child: Padding(
                            padding: AppSpacing.screenPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Row
                                StatsRow(
                                  points: user.totalPoints,
                                  streak: user.currentStreak,
                                  level: user.currentLevel,
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Plant Companion Card
                                PlantCompanionCard(
                                  plantName: stageName,
                                  evolutionStage: evolutionStage,
                                  currentXp: user.plantCurrentXp,
                                  requiredXp: nextLevelXp,
                                  health: user.plantHealth,
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Daily Challenge
                                if (state.dailyChallenge != null) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.blueGradient,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Today\'s Challenge',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              letterSpacing: -0.3,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  DailyChallengeCard(
                                    title: state.dailyChallenge!.title,
                                    description:
                                        state.dailyChallenge!.description,
                                    progress: challengeProgress,
                                    reward: state.dailyChallenge!.xpReward,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // Quick Actions
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.accentGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.flash_on_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Quick Actions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.md),

                                const QuickActionsSection(),

                                const SizedBox(height: AppSpacing.lg),

                                // Quick Links
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.purpleGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.dashboard_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Quick Links',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildQuickLink(
                                        context,
                                        icon: Icons.bar_chart_rounded,
                                        label: 'Statistics',
                                        gradient: AppColors.blueGradient,
                                        onTap: () {
                                          AppRouter.navigate(
                                            context,
                                            AppRouter.statistics,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildQuickLink(
                                        context,
                                        icon: Icons.workspace_premium_rounded,
                                        label: 'Achievements',
                                        gradient: AppColors.accentGradient,
                                        onTap: () {
                                          AppRouter.navigate(
                                            context,
                                            AppRouter.achievements,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildQuickLink(
                                        context,
                                        icon: Icons.flag_rounded,
                                        label: 'Goals',
                                        gradient: AppColors.purpleGradient,
                                        onTap: () {
                                          AppRouter.navigate(
                                            context,
                                            AppRouter.goals,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildQuickLink(
                                        context,
                                        icon: Icons.calendar_today_rounded,
                                        label: 'Calendar',
                                        gradient: AppColors.primaryGradient,
                                        onTap: () {
                                          AppRouter.navigate(
                                            context,
                                            AppRouter.calendar,
                                            arguments: state.todayActivities,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } catch (e, stackTrace) {
                  debugPrint('Error rendering home content: $e');
                  debugPrint('Stack: $stackTrace');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Rendering Content',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: $e',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<HomeBloc>()
                                  .add(const HomeDataLoadRequested());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              return _buildSkeletonLoader(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Skeleton App Bar
        SliverAppBar(
          floating: true,
          pinned: false,
          elevation: 0,
          backgroundColor: AppColors.primaryGreen,
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 16, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonLoader(width: 120, height: 24),
                                SizedBox(height: 8),
                                SkeletonLoader(width: 180, height: 16),
                              ],
                            ),
                          ),
                          SkeletonLoader(
                            width: 48,
                            height: 48,
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Skeleton Content
        const SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonStatsRow(),
                SizedBox(height: AppSpacing.lg),
                SkeletonCard(height: 200),
                SizedBox(height: AppSpacing.lg),
                SkeletonLoader(width: 150, height: 24),
                SizedBox(height: AppSpacing.md),
                SkeletonCard(height: 120),
                SizedBox(height: AppSpacing.lg),
                SkeletonLoader(width: 120, height: 24),
                SizedBox(height: AppSpacing.md),
                SkeletonCard(height: 100),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

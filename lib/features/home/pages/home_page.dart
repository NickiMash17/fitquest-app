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
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/repositories/challenge_repository.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/features/home/widgets/welcome_header.dart';
import 'package:fitquest/features/home/widgets/stats_row.dart';
import 'package:fitquest/features/home/widgets/quick_actions_section.dart';
import 'package:fitquest/features/home/widgets/daily_challenge_card.dart';
import 'package:fitquest/features/home/widgets/smart_insights_widget.dart';
import 'package:fitquest/shared/widgets/skeleton_loader.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/core/services/error_handler_service.dart';
import 'package:fitquest/core/widgets/premium_wellness_ring.dart';
import 'package:fitquest/core/widgets/premium_glass_card.dart';
import 'package:fitquest/core/widgets/enhanced_section_header.dart';
import 'package:fitquest/core/widgets/staggered_animation_wrapper.dart';
import 'package:fitquest/core/widgets/gamified_plant_avatar.dart';
import 'package:fitquest/features/home/utils/wellness_data_helper.dart';
import 'package:fitquest/features/home/data/models/wellness_data.dart';
import 'package:fitquest/core/widgets/enhanced_error_state.dart';
import 'package:fitquest/core/widgets/premium_toast.dart';
import 'package:fitquest/core/services/haptic_service.dart';

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
          // Fallback: create manually (silent in production)
          assert(() {
            debugPrint('Error creating HomeBloc: $e');
            return true;
          }());
          return HomeBloc(
            getIt<UserRepository>(),
            getIt<ChallengeRepository>(),
            getIt<ActivityRepository>(),
            getIt<FirebaseAuth>(),
            getIt<ErrorHandlerService>(),
          )..add(const HomeDataLoadRequested());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) {
              // Only rebuild when state type changes or data actually changes
              if (previous.runtimeType != current.runtimeType) return true;
              if (previous is HomeLoaded && current is HomeLoaded) {
                // Rebuild if user data or activities changed
                return previous.user.id != current.user.id ||
                    previous.todayActivities.length !=
                        current.todayActivities.length ||
                    previous.dailyChallenge?.id != current.dailyChallenge?.id;
              }
              return false;
            },
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
                return EnhancedErrorState(
                  title: 'Failed to Load',
                  message: state.message,
                  icon: Icons.error_outline_rounded,
                  onRetry: () {
                    context
                        .read<HomeBloc>()
                        .add(const HomeDataLoadRequested());
                  },
                  retryLabel: 'Try Again',
                );
              }

              if (state is HomeLoaded) {
                try {
                  final user = state.user;

                  // Pre-calculate values once (moved out of build for performance)
                  final challengeProgress = state.dailyChallenge != null &&
                          state.dailyChallenge!.targetValue > 0
                      ? (state.todayXp /
                              (state.dailyChallenge!.targetValue * 5))
                          .clamp(0.0, 1.0)
                      : 0.0;

                  // Safely calculate wellness data with error handling - MUST be before hero section
                  WellnessData wellnessData;
                  Map<String, double> progress;
                  try {
                    wellnessData = WellnessDataHelper.calculateWellnessData(
                      user: user,
                      todayActivities: state.todayActivities,
                    );
                    progress = WellnessDataHelper.calculateWellnessProgress(
                      wellnessData,
                    );
                  } catch (e, stackTrace) {
                    debugPrint('Error calculating wellness data: $e');
                    debugPrint('Stack trace: $stackTrace');
                    // Fallback to empty wellness data
                    wellnessData = WellnessData(
                      date: DateTime.now(),
                      workoutsCompleted: 0,
                      caloriesBurned: 0,
                      meditationMinutes: 0,
                      waterIntakeMl: 0,
                      sleepHours: 0,
                      sleepQuality: 0,
                      totalXP: 0,
                      exerciseCompleted: false,
                      meditationCompleted: false,
                      hydrationCompleted: false,
                      sleepCompleted: false,
                      exerciseConsistency: 0,
                      meditationRegularity: 0,
                      hydrationLevel: 0,
                    );
                    progress = {
                      'exercise': 0.0,
                      'meditation': 0.0,
                      'hydration': 0.0,
                      'sleep': 0.0,
                    };
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Revamped Hero Section with Plant Avatar
                      SliverAppBar(
                        floating: false,
                        pinned: true,
                        elevation: 0,
                        backgroundColor: Theme.of(context).brightness ==
                                Brightness.dark
                            ? AppColors.primaryDarkTheme
                            : AppColors.primaryGreen,
                        expandedHeight: 280,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final expandRatio =
                                ((constraints.maxHeight - kToolbarHeight) /
                                        (280 - kToolbarHeight))
                                    .clamp(0.0, 1.0);
                            final parallaxOffset = (1 - expandRatio) * 40;

                            return FlexibleSpaceBar(
                              background: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientNature,
                                ),
                                child: SafeArea(
                                  child: Stack(
                                    children: [
                                      // Background decorative elements
                                      Positioned(
                                        right: -50,
                                        top: 20,
                                        child: Opacity(
                                          opacity: 0.1 * expandRatio,
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  Colors.white.withValues(
                                                      alpha: 0.3),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Main content
                                      Transform.translate(
                                        offset: Offset(0, parallaxOffset * 0.3),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            20,
                                            16,
                                            16, // Reduced bottom padding to prevent overflow
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min, // Prevent overflow
                                            children: [
                                              // Top row: Welcome + Notifications
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Opacity(
                                                      opacity: expandRatio,
                                                      child: WelcomeHeader(
                                                          user: user),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withValues(alpha: 0.25),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.4),
                                                        width: 1.5,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Theme.of(
                                                                  context)
                                                              .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.black
                                                                  .withValues(
                                                                      alpha: 0.3)
                                                              : Colors.black
                                                                  .withValues(
                                                                      alpha: 0.1),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .notifications_outlined,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        // TODO: Navigate to notifications
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: expandRatio > 0.5 ? 16 : 8), // Dynamic spacing
                                              // Plant Avatar Section - More Prominent
                                              if (expandRatio > 0.3) // Only show when expanded enough
                                                Opacity(
                                                  opacity: expandRatio,
                                                  child: Builder(
                                                    builder: (context) {
                                                      try {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                HapticService.light();
                                                                AppRouter.navigate(
                                                                  context,
                                                                  AppRouter.plantDetail,
                                                                  arguments: user,
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape:
                                                                      BoxShape.circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withValues(
                                                                              alpha: 0.2),
                                                                      blurRadius: 20,
                                                                      spreadRadius: 2,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child:
                                                                    GamifiedPlantAvatar(
                                                                  level:
                                                                      user.currentLevel,
                                                                  wellnessData:
                                                                      wellnessData,
                                                                  size: 100, // Reduced from 120 to fit better
                                                                  showPersonality: true,
                                                                  onTap: () {
                                                                    HapticService
                                                                        .medium();
                                                                    AppRouter.navigate(
                                                                      context,
                                                                      AppRouter
                                                                          .plantDetail,
                                                                      arguments: user,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      } catch (e, stackTrace) {
                                                        debugPrint('Error rendering plant avatar in hero: $e');
                                                        debugPrint('Stack: $stackTrace');
                                                        return const SizedBox(
                                                          width: 100,
                                                          height: 100,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Main content
                      SliverToBoxAdapter(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            HapticService.light();
                            context
                                .read<HomeBloc>()
                                .add(const HomeDataRefreshRequested());
                            // Show success toast after refresh
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            if (context.mounted) {
                              PremiumToast.success(
                                context,
                                'Refreshed!',
                              );
                            }
                          },
                          color: AppColors.primaryGreen,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          strokeWidth: 3,
                          child: Padding(
                            padding: AppSpacing.screenPadding,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Row - Enhanced with better spacing
                                StaggeredAnimationWrapper(
                                  index: 0,
                                  child: StatsRow(
                                    points: user.totalPoints,
                                    streak: user.currentStreak,
                                    level: user.currentLevel,
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Wellness Ring Section - More Prominent
                                StaggeredAnimationWrapper(
                                  index: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      EnhancedSectionHeader(
                                        icon: Icons.favorite_rounded,
                                        title: 'Wellness Overview',
                                        subtitle:
                                            'Track your 4 wellness pillars',
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Center(
                                        child: Builder(
                                          builder: (context) {
                                            try {
                                              return PremiumGlassCard(
                                                padding: const EdgeInsets.all(28),
                                                elevated: true,
                                                child: PremiumWellnessRing(
                                                  exerciseProgress:
                                                      progress['exercise'] ?? 0.0,
                                                  meditationProgress:
                                                      progress['meditation'] ?? 0.0,
                                                  hydrationProgress:
                                                      progress['hydration'] ?? 0.0,
                                                  sleepProgress:
                                                      progress['sleep'] ?? 0.0,
                                                  level: user.currentLevel,
                                                ),
                                              );
                                            } catch (e) {
                                              debugPrint('Error rendering wellness ring: $e');
                                              return PremiumGlassCard(
                                                padding: const EdgeInsets.all(28),
                                                elevated: true,
                                                child: const SizedBox(
                                                  width: 200,
                                                  height: 200,
                                                  child: Center(
                                                    child: Text(
                                                      'Unable to load wellness data',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Daily Challenge - More Prominent
                                if (state.dailyChallenge != null) ...[
                                  StaggeredAnimationWrapper(
                                    index: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        EnhancedSectionHeader(
                                          icon: Icons.emoji_events_rounded,
                                          title: 'Daily Challenge',
                                          subtitle:
                                              'Complete to earn bonus XP',
                                          gradient: AppColors.blueGradient,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        DailyChallengeCard(
                                          title: state.dailyChallenge!.title,
                                          description: state
                                              .dailyChallenge!.description,
                                          progress: challengeProgress,
                                          reward:
                                              state.dailyChallenge!.xpReward,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                ],

                                // Quick Actions - Enhanced Layout
                                StaggeredAnimationWrapper(
                                  index: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      EnhancedSectionHeader(
                                        icon: Icons.flash_on_rounded,
                                        title: 'Quick Actions',
                                        subtitle: 'Start a wellness activity',
                                        gradient: AppColors.accentGradient,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      const QuickActionsSection(),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Smart Insights
                                StaggeredAnimationWrapper(
                                  index: 4,
                                  child: SmartInsightsWidget(user: user),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Quick Links - Enhanced Grid Layout
                                StaggeredAnimationWrapper(
                                  index: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      EnhancedSectionHeader(
                                        icon: Icons.dashboard_rounded,
                                        title: 'Quick Links',
                                        subtitle: 'Navigate to key features',
                                        gradient: AppColors.purpleGradient,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      _buildQuickLinksGrid(context, state),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } catch (e, _) {
                  // Error rendering - show error UI
                  return EnhancedErrorState(
                    title: 'Error Rendering Content',
                    message: 'Something went wrong. Please try again.',
                    icon: Icons.bug_report_rounded,
                    onRetry: () {
                      context
                          .read<HomeBloc>()
                          .add(const HomeDataLoadRequested());
                    },
                    retryLabel: 'Retry',
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

  Widget _buildQuickLinksGrid(BuildContext context, HomeLoaded state) {
    final links = [
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Statistics',
        'gradient': AppColors.blueGradient,
        'onTap': () {
          AppRouter.navigate(context, AppRouter.statistics);
        },
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'label': 'Achievements',
        'gradient': AppColors.accentGradient,
        'onTap': () {
          AppRouter.navigate(context, AppRouter.achievements);
        },
      },
      {
        'icon': Icons.flag_rounded,
        'label': 'Goals',
        'gradient': AppColors.purpleGradient,
        'onTap': () {
          AppRouter.navigate(context, AppRouter.goals);
        },
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'Calendar',
        'gradient': AppColors.primaryGradient,
        'onTap': () {
          AppRouter.navigate(
            context,
            AppRouter.calendar,
            arguments: state.todayActivities,
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return StaggeredAnimationWrapper(
          index: index,
          delay: const Duration(milliseconds: 50),
          child: _buildQuickLink(
            context,
            icon: link['icon'] as IconData,
            label: link['label'] as String,
            gradient: link['gradient'] as Gradient,
            onTap: link['onTap'] as VoidCallback,
          ),
        );
      },
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryDarkTheme
              : AppColors.primaryGreen,
          expandedHeight: 280,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradientNature,
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(24)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SkeletonLoader(
                          width: 120,
                          height: 120,
                          borderRadius:
                              BorderRadius.all(Radius.circular(60)),
                        ),
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
                SizedBox(height: AppSpacing.xl),
                SkeletonCard(height: 240),
                SizedBox(height: AppSpacing.xl),
                SkeletonLoader(width: 150, height: 24),
                SizedBox(height: AppSpacing.md),
                SkeletonCard(height: 140),
                SizedBox(height: AppSpacing.xl),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.shade500.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

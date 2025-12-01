// lib/features/activities/pages/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/repositories/activity_repository.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/shared/widgets/empty_state_widget.dart';
import 'package:fitquest/core/utils/date_utils.dart' as app_date_utils;
import 'package:fitquest/shared/models/activity_model.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          final bloc = getIt<ActivityBloc>();
          bloc.add(const ActivitiesLoadRequested());
          return bloc;
        } catch (e) {
          debugPrint('Error creating ActivityBloc: $e');
          // Fallback: create manually
          return ActivityBloc(
            getIt<ActivityRepository>(),
            getIt<UserRepository>(),
            getIt<XpCalculatorService>(),
            getIt<FirebaseAuth>(),
          )..add(const ActivitiesLoadRequested());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Activities',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            debugPrint('ActivitiesPage state: ${state.runtimeType}');

            // Handle initial state - trigger load
            if (state is ActivityInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context
                    .read<ActivityBloc>()
                    .add(const ActivitiesLoadRequested());
              });
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ActivityLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ActivityError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(state.message),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ActivityBloc>()
                              .add(const ActivitiesLoadRequested());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ActivityLoaded) {
              debugPrint(
                  'ActivitiesPage: Loaded ${state.activities.length} activities');
              try {
                if (state.activities.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No Activities Yet',
                    message: 'Start logging your activities to see them here!',
                    icon: Icons.directions_run_outlined,
                    action: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.addActivity);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Log Your First Activity'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ActivityBloc>()
                        .add(const ActivitiesLoadRequested());
                  },
                  child: ListView(
                    padding: AppSpacing.screenPadding,
                    children: [
                      // Recent activities
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Recent Activities',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...state.activities.take(10).map((activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActivityCard(context, activity),
                          )),
                      const SizedBox(height: AppSpacing.lg),
                      // Activity categories
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
                            'Quick Log',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildActivityCategory(
                        context,
                        title: 'Exercise',
                        icon: Icons.directions_run,
                        color: Colors.blue,
                        items: const [
                          'Running',
                          'Cycling',
                          'Swimming',
                          'Yoga',
                          'Strength Training',
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActivityCategory(
                        context,
                        title: 'Mindfulness',
                        icon: Icons.self_improvement,
                        color: Colors.purple,
                        items: const [
                          'Meditation',
                          'Deep Breathing',
                          'Gratitude Journal',
                          'Mindful Walking',
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActivityCategory(
                        context,
                        title: 'Nutrition',
                        icon: Icons.restaurant,
                        color: Colors.green,
                        items: const [
                          'Water Intake',
                          'Healthy Meals',
                          'Meal Prep',
                          'Nutrition Log',
                        ],
                      ),
                    ],
                  ),
                );
              } catch (e, stackTrace) {
                debugPrint('Error rendering activities: $e');
                debugPrint('Stack: $stackTrace');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error Rendering Activities',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Error: $e'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ActivityBloc>()
                                .add(const ActivitiesLoadRequested());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }

            // Fallback - should never reach here, but just in case
            debugPrint('ActivitiesPage: Unknown state ${state.runtimeType}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline,
                      size: 64, color: Color(0xFF616161)),
                  const SizedBox(height: 16),
                  Text(
                    'Unknown State',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('State: ${state.runtimeType}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ActivityBloc>()
                          .add(const ActivitiesLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.addActivity);
          },
          backgroundColor: AppColors.primaryGreen,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Log Activity',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final activityColor = _getActivityColor(activity.type);
    final activityGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        activityColor,
        activityColor.withOpacity(0.7),
      ],
    );

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      showShadow: true,
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: activityGradient,
              borderRadius: AppBorderRadius.allMD,
              boxShadow: AppShadows.primaryShadow(activityColor),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTypeName(activity.type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      app_date_utils.DateUtils.formatDateTime(activity.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // XP and duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppBorderRadius.allSM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${activity.xpEarned}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activity.duration} min',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActivityTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return 'Exercise';
      case ActivityType.meditation:
        return 'Meditation';
      case ActivityType.hydration:
        return 'Hydration';
      case ActivityType.sleep:
        return 'Sleep';
      default:
        return 'Activity';
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return Icons.directions_run;
      case ActivityType.meditation:
        return Icons.self_improvement;
      case ActivityType.hydration:
        return Icons.water_drop;
      case ActivityType.sleep:
        return Icons.nightlight_round;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return Colors.blue;
      case ActivityType.meditation:
        return Colors.purple;
      case ActivityType.hydration:
        return Colors.lightBlue;
      case ActivityType.sleep:
        return Colors.indigo;
      default:
        return const Color(0xFF616161); // Darker grey for better contrast
    }
  }

  Widget _buildActivityCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildActivityItem(context, item, color)),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_circle_outline, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: Color(0xFF757575)), // Better contrast
        onTap: () {
          Navigator.of(context).pushNamed(AppRouter.addActivity);
        },
      ),
    );
  }
}

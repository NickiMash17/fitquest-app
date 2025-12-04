import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/skeleton_loader.dart';
import 'package:fitquest/shared/widgets/empty_state_widget.dart';
import 'package:fitquest/features/statistics/widgets/activity_chart.dart';
import 'package:fitquest/shared/models/activity_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Ensure activities are loaded for statistics
    context.read<ActivityBloc>().add(const ActivitiesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading || state is ActivityInitial) {
            return _buildSkeletonLoader(context);
          }

          if (state is ActivityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<ActivityBloc>()
                          .add(const ActivitiesLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ActivityLoaded) {
            if (state.activities.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Data Yet',
                message: 'Log some activities to see your statistics here!',
                icon: Icons.bar_chart_rounded,
              );
            }
            return _buildStatisticsContent(context, state.activities);
          }

          return _buildSkeletonLoader(context);
        },
      ),
    );
  }

  Widget _buildStatisticsContent(
    BuildContext context,
    List<ActivityModel> activities,
  ) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Filter activities for this week
    final weekActivities = activities.where((activity) {
      final activityDate = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      return activityDate
              .isAfter(weekStart.subtract(const Duration(days: 1))) &&
          activityDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    // Calculate overall statistics (all activities)
    final totalMinutes = activities.fold<int>(
      0,
      (sum, activity) => sum + activity.duration,
    );
    final totalXp = activities.fold<int>(
      0,
      (sum, activity) => sum + activity.xpEarned,
    );
    final activityCount = activities.length;

    // Calculate weekly average
    final daysSinceFirstActivity = activities.isNotEmpty
        ? now
                .difference(
                  activities
                      .map((a) => a.date)
                      .reduce((a, b) => a.isBefore(b) ? a : b),
                )
                .inDays +
            1
        : 1;
    final avgPerDay = daysSinceFirstActivity > 0
        ? (totalMinutes / daysSinceFirstActivity).toStringAsFixed(0)
        : '0';

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Total Minutes',
                  value: '$totalMinutes',
                  icon: Icons.timer_rounded,
                  gradient: AppColors.blueGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Total XP',
                  value: '$totalXp',
                  icon: Icons.star_rounded,
                  gradient: AppColors.primaryGradient,
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
                  title: 'Activities',
                  value: '$activityCount',
                  icon: Icons.directions_run_rounded,
                  gradient: AppColors.accentGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Avg/Day',
                  value: avgPerDay,
                  icon: Icons.trending_up_rounded,
                  gradient: AppColors.purpleGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Weekly chart
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Weekly Activity',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ],
                  ),
                ),
                ActivityChart(
                  activities: weekActivities,
                  startDate: weekStart,
                  endDate: weekEnd,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Activity breakdown
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pie_chart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Activity Breakdown',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildActivityBreakdown(context, weekActivities),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityBreakdown(
    BuildContext context,
    List<ActivityModel> activities,
  ) {
    final breakdown = <ActivityType, int>{};
    for (final activity in activities) {
      breakdown[activity.type] =
          (breakdown[activity.type] ?? 0) + activity.duration;
    }

    final total = breakdown.values.fold<int>(0, (sum, value) => sum + value);

    if (breakdown.isEmpty) {
      return [
        Text(
          'No activities yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ];
    }

    return breakdown.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getActivityTypeName(entry.key),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  '${entry.value} min (${percentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getActivityColor(entry.key),
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    }).toList();
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
    }
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return const SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              SizedBox(width: 12),
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              SizedBox(width: 12),
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          SkeletonCard(height: 300),
        ],
      ),
    );
  }
}

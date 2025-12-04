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
import 'package:fitquest/shared/widgets/skeleton_loader.dart';
import 'package:fitquest/shared/widgets/search_bar_widget.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  String _searchQuery = '';
  ActivityType? _filterType;

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
              return _buildSkeletonLoader(context);
            }

            if (state is ActivityLoading) {
              return _buildSkeletonLoader(context);
            }

            if (state is ActivityError) {
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
                'ActivitiesPage: Loaded ${state.activities.length} activities',
              );
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

                // Filter activities based on search and filter
                final filteredActivities = _filterActivities(
                  state.activities,
                  _searchQuery,
                  _filterType,
                );

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ActivityBloc>()
                        .add(const ActivitiesLoadRequested());
                  },
                  child: ListView(
                    padding: AppSpacing.screenPadding,
                    children: [
                      // Search bar
                      SearchBarWidget(
                        hintText: 'Search activities...',
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: 'All',
                              isSelected: _filterType == null,
                              onTap: () {
                                setState(() {
                                  _filterType = null;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ...ActivityType.values.map(
                              (type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildFilterChip(
                                  context,
                                  label: _getActivityTypeName(type),
                                  isSelected: _filterType == type,
                                  onTap: () {
                                    setState(() {
                                      _filterType =
                                          _filterType == type ? null : type;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Recent activities header
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const Spacer(),
                          if (_searchQuery.isNotEmpty || _filterType != null)
                            Text(
                              '${filteredActivities.length} found',
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
                      const SizedBox(height: AppSpacing.md),
                      if (filteredActivities.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No activities found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
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
                        )
                      else
                        ...filteredActivities.map(
                          (activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActivityCard(context, activity),
                          ),
                        ),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
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
                  const Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Color(0xFF616161),
                  ),
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

  Widget _buildSkeletonLoader(BuildContext context) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        const SkeletonLoader(width: 150, height: 24),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(5, (index) => const SkeletonListItem()),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLoader(width: 120, height: 24),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(4, (index) => const SkeletonListItem()),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    final activityColor = _getActivityColor(activity.type);
    final activityGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        activityColor,
        activityColor.withValues(alpha: 0.7),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      app_date_utils.DateUtils.formatDateTime(activity.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                decoration: const BoxDecoration(
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF757575),
        ), // Better contrast
        onTap: () {
          Navigator.of(context).pushNamed(AppRouter.addActivity);
        },
      ),
    );
  }

  List<ActivityModel> _filterActivities(
    List<ActivityModel> activities,
    String searchQuery,
    ActivityType? filterType,
  ) {
    var filtered = activities;

    // Filter by type
    if (filterType != null) {
      filtered = filtered.where((a) => a.type == filterType).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((activity) {
        final typeName = _getActivityTypeName(activity.type).toLowerCase();
        final notes = activity.notes?.toLowerCase() ?? '';
        return typeName.contains(query) || notes.contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.primaryGreen
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}

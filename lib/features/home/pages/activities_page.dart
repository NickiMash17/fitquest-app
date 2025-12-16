// lib/features/activities/pages/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/widgets/empty_state_widget.dart';
import 'package:fitquest/core/utils/date_utils.dart' as app_date_utils;
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/shared/widgets/skeleton_loader.dart';
import 'package:fitquest/shared/widgets/search_bar_widget.dart';
import 'package:fitquest/shared/widgets/swipeable_card.dart';
import 'package:fitquest/shared/widgets/image_with_fallback.dart';
import 'package:fitquest/shared/widgets/floating_action_button_extended_premium.dart';
import 'package:fitquest/core/utils/activity_image_helper.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  String _searchQuery = '';
  ActivityType? _filterType;

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if we haven't loaded yet and state is not already loaded
    if (!_hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<ActivityBloc>();
          // Only reload if we're not already loading and not already loaded
          if (bloc.state is! ActivityLoading && bloc.state is! ActivityLoaded) {
            _hasLoaded = true;
            bloc.add(const ActivitiesLoadRequested());
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Don't load here - let didChangeDependencies handle it
    // This prevents duplicate loads
  }

  @override
  Widget build(BuildContext context) {
    // Use the ActivityBloc from the app level (provided in main.dart)
    // Don't create a new instance - this ensures state is shared
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<ActivityBloc, ActivityState>(
        listener: (context, state) {
          // Reload activities when returning from add activity page
          // No debugPrint needed - listener handles state changes
        },
        buildWhen: (previous, current) {
          // Only rebuild when state actually changes
          return previous.runtimeType != current.runtimeType ||
              (previous is ActivityLoaded &&
                  current is ActivityLoaded &&
                  previous.activities.length != current.activities.length);
        },
        builder: (context, state) {
          // Handle initial state - trigger load
          if (state is ActivityInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ActivityBloc>().add(const ActivitiesLoadRequested());
            });
            return _buildSkeletonLoader(context);
          }

          if (state is ActivityLoading) {
            return _buildSkeletonLoader(context);
          }

          if (state is ActivityError) {
            return SingleChildScrollView(
              child: Center(
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
                          context.read<ActivityBloc>().add(
                            const ActivitiesLoadRequested(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is ActivityLoaded) {
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
                  context.read<ActivityBloc>().add(
                    const ActivitiesLoadRequested(),
                  );
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
                                    _filterType = _filterType == type
                                        ? null
                                        : type;
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Recent Activities',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const Spacer(),
                        if (_searchQuery.isNotEmpty || _filterType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: AppBorderRadius.allMD,
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${filteredActivities.length} found',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Use ListView.builder for better performance
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredActivities.length,
                        cacheExtent: 500,
                        itemBuilder: (context, index) {
                          final activity = filteredActivities[index];
                          return RepaintBoundary(
                            key: ValueKey('activity_${activity.id}_$index'),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildActivityCard(context, activity),
                            ),
                          );
                        },
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
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
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
            } catch (e) {
              // Error rendering - show error UI without logging
              return SingleChildScrollView(
                child: Center(
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
                            context.read<ActivityBloc>().add(
                              const ActivitiesLoadRequested(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }

          // Fallback - should never reach here, but just in case
          return SingleChildScrollView(
            child: Center(
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
                      context.read<ActivityBloc>().add(
                        const ActivitiesLoadRequested(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: PremiumFloatingActionButton(
        label: 'Log Activity',
        icon: Icons.add_rounded,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.addActivity);
        },
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
      colors: [activityColor, activityColor.withValues(alpha: 0.7)],
    );

    return SwipeableCard(
      leftAction: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 24,
      ),
      rightAction: const Icon(
        Icons.edit_outlined,
        color: Colors.white,
        size: 24,
      ),
      leftActionColor: Colors.red,
      rightActionColor: AppColors.primaryGreen,
      onSwipeLeft: () {
        // Show delete confirmation
        _showDeleteConfirmation(context, activity);
      },
      onSwipeRight: () {
        // Navigate to edit activity
        Navigator.of(
          context,
        ).pushNamed(AppRouter.addActivity, arguments: activity);
      },
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        showShadow: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: activityColor.withValues(alpha: 0.1),
          width: 1,
        ),
        child: Row(
          children: [
            // Enhanced Activity image with gradient background
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: activityGradient,
                borderRadius: AppBorderRadius.allLG,
                boxShadow: [
                  BoxShadow(
                    color: activityColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => _showActivityDetails(context, activity),
                child: ClipRRect(
                  borderRadius: AppBorderRadius.allLG,
                  child: ImageWithFallback(
                    imageUrl: ActivityImageHelper.getActivityImageUrl(
                      activity.type,
                    ),
                    assetPath: ActivityImageHelper.getActivityImagePath(
                      activity.type,
                    ),
                    fallbackIcon: ActivityImageHelper.getActivityIcon(
                      activity.type,
                    ),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    backgroundGradient: activityGradient,
                    iconColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Enhanced Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityTypeName(activity.type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
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
                          color: activityColor.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.allSM,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: activityColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app_date_utils.DateUtils.formatDateTime(
                                activity.date,
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: activityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (activity.duration > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: AppBorderRadius.allSM,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_rounded,
                                size: 14,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${activity.duration}min',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      activity.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(BuildContext context, ActivityModel activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ImageWithFallback(
                        imageUrl: ActivityImageHelper.getActivityImageUrl(
                          activity.type,
                        ),
                        assetPath: ActivityImageHelper.getActivityImagePath(
                          activity.type,
                        ),
                        fallbackIcon: ActivityImageHelper.getActivityIcon(
                          activity.type,
                        ),
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        backgroundColor: _getActivityColor(
                          activity.type,
                        ).withValues(alpha: 0.1),
                        iconColor: _getActivityColor(activity.type),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getActivityTypeName(activity.type),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      context,
                      icon: Icons.access_time_rounded,
                      label: 'Date & Time',
                      value: app_date_utils.DateUtils.formatDateTime(
                        activity.date,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      context,
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: '${activity.duration} minutes',
                    ),
                    if (activity.xpEarned > 0) ...[
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        context,
                        icon: Icons.star_rounded,
                        label: 'XP Earned',
                        value: '+${activity.xpEarned}',
                      ),
                    ],
                    if (activity.notes != null &&
                        activity.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        context,
                        icon: Icons.note_outlined,
                        label: 'Notes',
                        value: activity.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _getActivityColor(ActivityType.exercise)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity?'),
        content: Text(
          'Are you sure you want to delete this ${_getActivityTypeName(activity.type).toLowerCase()} activity?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
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
    // First, deduplicate by ID to ensure no duplicates
    final seenIds = <String>{};
    var filtered = activities.where((activity) {
      if (seenIds.contains(activity.id)) {
        return false; // Skip duplicate
      }
      seenIds.add(activity.id);
      return true;
    }).toList();

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppBorderRadius.allMD,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            if (isSelected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

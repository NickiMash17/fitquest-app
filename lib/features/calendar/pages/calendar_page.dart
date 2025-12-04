import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/utils/date_utils.dart' as date_utils;

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class CalendarPage extends StatefulWidget {
  final List<ActivityModel> activities;

  const CalendarPage({
    super.key,
    required this.activities,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late ValueNotifier<List<ActivityModel>> _selectedActivities;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedActivities = ValueNotifier(_getActivitiesForDay(_selectedDay));
  }

  @override
  void dispose() {
    _selectedActivities.dispose();
    super.dispose();
  }

  List<ActivityModel> _getActivitiesForDay(DateTime day) {
    return widget.activities.where((activity) {
      return activity.date.year == day.year &&
          activity.date.month == day.month &&
          activity.date.day == day.day;
    }).toList();
  }

  Map<DateTime, List<ActivityModel>> _getActivitiesMap() {
    final Map<DateTime, List<ActivityModel>> activitiesMap = {};
    for (final activity in widget.activities) {
      final day = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      if (activitiesMap.containsKey(day)) {
        activitiesMap[day]!.add(activity);
      } else {
        activitiesMap[day] = [activity];
      }
    }
    return activitiesMap;
  }

  @override
  Widget build(BuildContext context) {
    final activitiesMap = _getActivitiesMap();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar
          PremiumCard(
            margin: AppSpacing.screenPadding,
            padding: EdgeInsets.zero,
            child: TableCalendar<ActivityModel>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => activitiesMap[day] ?? [],
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                selectedDecoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ) ??
                        const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedActivities.value =
                        _getActivitiesForDay(selectedDay);
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          // Selected day activities
          Expanded(
            child: ValueListenableBuilder<List<ActivityModel>>(
              valueListenable: _selectedActivities,
              builder: (context, activities, _) {
                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities on this day',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActivityCard(context, activity),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityModel activity) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getActivityColor(activity.type),
                  _getActivityColor(activity.type).withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTypeName(activity.type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  date_utils.DateUtils.formatTime(activity.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${activity.xpEarned} XP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${activity.duration} min',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}

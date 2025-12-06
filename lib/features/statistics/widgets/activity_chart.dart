import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Interactive activity chart widget showing weekly activity trends
class ActivityChart extends StatefulWidget {
  final List<ActivityModel> activities;
  final DateTime startDate;
  final DateTime endDate;

  const ActivityChart({
    super.key,
    required this.activities,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  int? _selectedBarIndex;

  @override
  Widget build(BuildContext context) {
    // Group activities by day
    final dailyData = _groupActivitiesByDay(widget.activities, widget.startDate, widget.endDate);

    if (dailyData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              dailyData.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = dailyData.keys.elementAt(groupIndex);
                final activities = widget.activities.where((a) {
                  final dayStart = DateTime(a.date.year, a.date.month, a.date.day);
                  return dayStart == date;
                }).toList();
                return BarTooltipItem(
                  '${rod.toY.toInt()} min\n${activities.length} activities',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (event is FlTapUpEvent && barTouchResponse?.spot != null) {
                setState(() {
                  _selectedBarIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
                });
                HapticFeedbackService.lightImpact();
                // Show detailed info for the selected day
                _showDayDetails(context, dailyData.keys.elementAt(_selectedBarIndex!));
              }
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyData.length) {
                    final date = dailyData.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _getDayLabel(date),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: dailyData.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  color: _selectedBarIndex == index
                      ? AppColors.primaryGreen.withValues(alpha: 0.8)
                      : AppColors.primaryGreen,
                  width: _selectedBarIndex == index ? 20 : 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: dailyData.values
                            .reduce((a, b) => a > b ? a : b)
                            .toDouble() *
                        1.2,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<DateTime, int> _groupActivitiesByDay(
    List<ActivityModel> activities,
    DateTime start,
    DateTime end,
  ) {
    final Map<DateTime, int> dailyData = {};

    // Initialize all days with 0
    for (var date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(const Duration(days: 1))) {
      final dayStart = DateTime(date.year, date.month, date.day);
      dailyData[dayStart] = 0;
    }

    // Sum activities by day
    for (final activity in activities) {
      final dayStart = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      if (dailyData.containsKey(dayStart)) {
        dailyData[dayStart] = (dailyData[dayStart] ?? 0) + activity.duration;
      }
    }

    return dailyData;
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayStart = DateTime(date.year, date.month, date.day);

    if (dayStart == today) {
      return 'Today';
    } else if (dayStart == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return _getDayName(date.weekday);
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  void _showDayDetails(BuildContext context, DateTime date) {
    final dayActivities = widget.activities.where((a) {
      final dayStart = DateTime(a.date.year, a.date.month, a.date.day);
      return dayStart == date;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDayLabel(date),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dayActivities.length} activities • ${dayActivities.fold<int>(0, (sum, a) => sum + a.duration)} minutes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: dayActivities.isEmpty
                        ? Center(
                            child: Text(
                              'No activities on this day',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: dayActivities.length,
                            itemBuilder: (context, index) {
                              final activity = dayActivities[index];
                              return ListTile(
                                leading: Icon(
                                  _getActivityIcon(activity.type),
                                  color: AppColors.primaryGreen,
                                ),
                                title: Text(_getActivityTypeName(activity.type)),
                                subtitle: Text('${activity.duration} minutes'),
                                trailing: Text(
                                  '+${activity.xpEarned} XP',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return Icons.directions_run_rounded;
      case ActivityType.meditation:
        return Icons.self_improvement_rounded;
      case ActivityType.hydration:
        return Icons.water_drop_rounded;
      case ActivityType.sleep:
        return Icons.nightlight_round_rounded;
    }
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
}

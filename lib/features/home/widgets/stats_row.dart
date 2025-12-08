// lib/features/home/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/animated_counter.dart';

class StatsRow extends StatelessWidget {
  final int points;
  final int streak;
  final int level;

  const StatsRow({
    super.key,
    required this.points,
    required this.streak,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.star_rounded,
            value: points.toString(),
            label: 'Points',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            ),
            iconColor: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'Day Streak',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
            ),
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.emoji_events_rounded,
            value: 'Lvl $level',
            label: 'Level',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
    required Color iconColor,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      showShadow: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        width: 1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: _extractNumber(value),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
            prefix: value.startsWith('Lvl') ? 'Lvl ' : null,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _extractNumber(String value) {
    // Extract number from string (handles "Lvl 5" or "123")
    final match = RegExp(r'\d+').firstMatch(value);
    return match != null ? int.parse(match.group(0)!) : 0;
  }
}

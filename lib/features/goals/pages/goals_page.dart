import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/premium_button.dart';
import 'package:fitquest/shared/models/goal_model.dart';
import 'package:fitquest/shared/repositories/goal_repository.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/features/goals/widgets/create_goal_dialog.dart';
import 'package:fitquest/core/services/error_handler_service.dart';
import 'package:fitquest/core/utils/secure_logger.dart';
import 'package:fitquest/shared/widgets/enhanced_snackbar.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalRepository _goalRepository = getIt<GoalRepository>();
  final FirebaseAuth _auth = getIt<FirebaseAuth>();
  final ErrorHandlerService _errorHandler = getIt<ErrorHandlerService>();
  List<GoalModel> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final goals = await _goalRepository.getGoals(userId);
      if (mounted) {
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      SecureLogger.e('Error loading goals', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final message = _errorHandler.handleError(e, type: ErrorType.unknown);
        EnhancedSnackBar.showError(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Goals',
              style: TextStyle(fontWeight: FontWeight.bold),),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body:
          _goals.isEmpty ? _buildEmptyState(context) : _buildGoalsList(context),
      floatingActionButton: Semantics(
        label: 'Create new goal',
        hint: 'Double tap to open goal creation dialog',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddGoalDialog(context),
          backgroundColor: AppColors.primaryGreen,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Goal',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Goals Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set goals to track your progress and stay motivated!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              label: 'Create Your First Goal',
              icon: Icons.add_rounded,
              onPressed: () => _showAddGoalDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _goals.length,
      // Add cacheExtent for better performance
      cacheExtent: 500,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGoalCard(context, goal),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final progress = goal.targetValue > 0
        ? (goal.currentProgress / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final daysRemaining = goal.endDate.difference(DateTime.now()).inDays;

    return Semantics(
      label: 'Goal: ${goal.title}. Progress: ${goal.currentProgress} of ${goal.targetValue} ${goal.targetUnit}. ${daysRemaining > 0 ? '$daysRemaining days remaining' : 'Expired'}',
      hint: 'Double tap to view goal details',
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: _getGoalTypeGradient(goal.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGoalTypeIcon(goal.type),
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
                      goal.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, goal.status),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getGoalTypeColor(goal.type),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentProgress} / ${goal.targetValue} ${goal.targetUnit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                daysRemaining > 0 ? '$daysRemaining days left' : 'Expired',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: daysRemaining > 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, GoalStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case GoalStatus.active:
        color = AppColors.success;
        label = 'Active';
        icon = Icons.check_circle_rounded;
        break;
      case GoalStatus.completed:
        color = AppColors.primaryGreen;
        label = 'Done';
        icon = Icons.emoji_events_rounded;
        break;
      case GoalStatus.failed:
        color = AppColors.error;
        label = 'Failed';
        icon = Icons.cancel_rounded;
        break;
      case GoalStatus.paused:
        color = AppColors.warning;
        label = 'Paused';
        icon = Icons.pause_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Gradient _getGoalTypeGradient(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return AppColors.primaryGradient;
      case GoalType.weekly:
        return AppColors.blueGradient;
      case GoalType.monthly:
        return AppColors.purpleGradient;
      case GoalType.custom:
        return AppColors.accentGradient;
    }
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return AppColors.primaryGreen;
      case GoalType.weekly:
        return AppColors.accentBlue;
      case GoalType.monthly:
        return AppColors.accentPurple;
      case GoalType.custom:
        return AppColors.accentOrange;
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return Icons.today_rounded;
      case GoalType.weekly:
        return Icons.date_range_rounded;
      case GoalType.monthly:
        return Icons.calendar_month_rounded;
      case GoalType.custom:
        return Icons.flag_rounded;
    }
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateGoalDialog(),
    );

    if (result == true) {
      // Reload goals after successful creation
      _loadGoals();
    }
  }
}

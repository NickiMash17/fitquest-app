import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_constants.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
import 'package:fitquest/features/activities/bloc/activity_state.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/shared/widgets/enhanced_snackbar.dart';
import 'package:fitquest/shared/widgets/premium_button.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/premium_text_field.dart';
import 'package:fitquest/shared/services/xp_calculator_service.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

class AddActivityPage extends StatefulWidget {
  final ActivityType? initialType;

  const AddActivityPage({super.key, this.initialType});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  ActivityType? _selectedType;
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late final XpCalculatorService _xpCalculator;
  bool _isSubmitting = false;
  int? _lastXp;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ActivityType.exercise;
    _xpCalculator = getIt<XpCalculatorService>();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      final duration = int.tryParse(_durationController.text) ?? 0;
      if (duration <= 0) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid duration')),
        );
        return;
      }

      final activity = ActivityModel(
        id: '',
        userId: '',
        type: _selectedType!,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
        duration: duration,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        glasses: _selectedType == ActivityType.hydration ? duration : null,
        hours: _selectedType == ActivityType.sleep ? duration : null,
      );

      _lastXp = _xpCalculator.calculateXp(activity);

      // Dispatch create event
      debugPrint('AddActivityPage: Dispatching ActivityCreateRequested event');
      debugPrint('AddActivityPage: Activity type: ${activity.type}, duration: ${activity.duration}');
      final bloc = context.read<ActivityBloc>();
      debugPrint('AddActivityPage: Current bloc state: ${bloc.state.runtimeType}');
      bloc.add(ActivityCreateRequested(activity: activity));
      debugPrint('AddActivityPage: Event dispatched, waiting for state change...');
      
      // Set a timeout - if we don't get a response in 10 seconds, show error
      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && _isSubmitting) {
          debugPrint('AddActivityPage: TIMEOUT - No response after 10 seconds');
          _handleActivityError('Request timed out. Please check your connection and try again.');
        }
      });
    }
  }

  void _handleActivityCreated() {
    if (!mounted || !_isSubmitting) return;
    
    _timeoutTimer?.cancel();
    debugPrint('AddActivityPage: Activity created successfully, navigating back');
    
    final xp = _lastXp ?? 0;

    setState(() {
      _isSubmitting = false;
    });

    // Navigate back immediately
    Navigator.of(context).pop();
    
    // Trigger a reload on the activities page
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        debugPrint('AddActivityPage: Triggering reload on activities page');
        context.read<ActivityBloc>().add(const ActivitiesLoadRequested());
      }
    });
    
    // Show success message after navigation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        EnhancedSnackBar.showSuccess(
          context,
          'Activity logged successfully! +$xp XP',
        );
      }
    });
  }

  void _handleActivityError(String message) {
    if (!mounted) return;

    _timeoutTimer?.cancel();
    
    setState(() {
      _isSubmitting = false;
    });

    debugPrint('AddActivityPage: Showing error to user: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listenWhen: (previous, current) {
        debugPrint('AddActivityPage: listenWhen - previous: ${previous.runtimeType}, current: ${current.runtimeType}, submitting: $_isSubmitting');
        
        // Only listen when we're submitting
        if (!_isSubmitting) {
          debugPrint('AddActivityPage: Not submitting, ignoring state change');
          return false;
        }

        // Handle any error state
        if (current is ActivityError) {
          debugPrint('AddActivityPage: Error state detected, will handle');
          return true;
        }

        // Handle ActivityLoading - log it
        if (current is ActivityLoading) {
          debugPrint('AddActivityPage: Loading state detected');
          return false; // Don't navigate on loading, just log
        }

        // Handle ActivityLoaded - always trigger when we see it after submitting
        if (current is ActivityLoaded) {
          debugPrint('AddActivityPage: ActivityLoaded detected with ${current.activities.length} activities');
          // Always trigger if we're submitting - this means creation completed
          return true;
        }

        debugPrint('AddActivityPage: State change not handled: ${current.runtimeType}');
        return false;
      },
      listener: (context, state) {
        if (!_isSubmitting) return;

        debugPrint('AddActivityPage: State changed to ${state.runtimeType}');
        
        if (state is ActivityError) {
          debugPrint('AddActivityPage: Error - ${state.message}');
          _handleActivityError(state.message);
        } else if (state is ActivityLoaded) {
          debugPrint('AddActivityPage: Activities loaded - ${state.activities.length} activities');
          // Activity was created and activities reloaded
          // Navigate back immediately - the activities page will show the updated list
          if (mounted && _isSubmitting) {
            _handleActivityCreated();
          }
        } else if (state is ActivityLoading) {
          debugPrint('AddActivityPage: Activity creation in progress...');
          // Keep showing loading state
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Activity'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Enhanced Activity type selector
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Activity Type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ActivityType.values.map((type) {
                    final isSelected = _selectedType == type;
                    final color = _getActivityTypeColor(type);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    color,
                                    color.withValues(alpha: 0.8),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: AppBorderRadius.allMD,
                          border: Border.all(
                            color: isSelected
                                ? color
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                            width: isSelected ? 0 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getActivityTypeIcon(type),
                              color: isSelected ? Colors.white : color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getActivityTypeName(type),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Enhanced Date picker
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PremiumCard(
                  padding: const EdgeInsets.all(16),
                  onTap: _selectDate,
                  showShadow: true,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.allMD,
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.accentBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to change',
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
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Enhanced Duration field
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentOrange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.timer_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getDurationLabel(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _durationController,
                  hintText: _getDurationHint(),
                  prefixIcon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Duration is required';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Please enter a valid duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Enhanced Notes field
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notes (Optional)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _notesController,
                  hintText: 'Add any additional notes...',
                  prefixIcon: Icons.note_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                // Premium Submit button
                PremiumButton(
                  label: 'Log Activity',
                  icon: Icons.add_rounded,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  isLoading: _isSubmitting,
                  gradient: AppColors.primaryGradient,
                ),
              ],
            ),
          ),
        ),
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

  String _getDurationLabel() {
    switch (_selectedType) {
      case ActivityType.exercise:
      case ActivityType.meditation:
        return 'Duration (minutes)';
      case ActivityType.hydration:
        return 'Glasses of Water';
      case ActivityType.sleep:
        return 'Hours of Sleep';
      case null:
        return 'Duration';
    }
  }

  String _getDurationHint() {
    switch (_selectedType) {
      case ActivityType.exercise:
      case ActivityType.meditation:
        return 'e.g., 30';
      case ActivityType.hydration:
        return 'e.g., 8';
      case ActivityType.sleep:
        return 'e.g., 8';
      case null:
        return 'Enter value';
    }
  }

  Color _getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.exercise:
        return AppColors.accentPurple;
      case ActivityType.meditation:
        return AppColors.accentBlue;
      case ActivityType.hydration:
        return const Color(0xFF03A9F4);
      case ActivityType.sleep:
        return const Color(0xFF5C6BC0);
    }
  }

  IconData _getActivityTypeIcon(ActivityType type) {
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
}

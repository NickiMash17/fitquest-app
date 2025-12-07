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
import 'package:fitquest/shared/services/xp_calculator_service.dart';

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
                // Activity type selector
                Text(
                  'Activity Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ActivityType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(_getActivityTypeName(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Date picker
                Text(
                  'Date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
                const SizedBox(height: 24),
                // Duration field
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _getDurationLabel(),
                    hintText: _getDurationHint(),
                    prefixIcon: const Icon(Icons.timer_outlined),
                  ),
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
                // Notes field
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any additional notes...',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log Activity'),
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
}

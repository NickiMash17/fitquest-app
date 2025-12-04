import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_constants.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/features/activities/bloc/activity_bloc.dart';
import 'package:fitquest/features/activities/bloc/activity_event.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? ActivityType.exercise;
    _xpCalculator = getIt<XpCalculatorService>();
  }

  @override
  void dispose() {
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      if (duration <= 0) {
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

      context
          .read<ActivityBloc>()
          .add(ActivityCreateRequested(activity: activity));

      if (mounted) {
        Navigator.of(context).pop();
        // Use enhanced snackbar for better UX
        EnhancedSnackBar.showSuccess(
          context,
          'Activity logged successfully! +${_xpCalculator.calculateXp(activity)} XP',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Log Activity'),
              ),
            ],
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

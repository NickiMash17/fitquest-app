// lib/features/home/pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/custom_plant_widget.dart';
import 'package:fitquest/shared/services/plant_service.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/models/user_model.dart';
import 'package:fitquest/shared/repositories/user_repository.dart';

class PlantDetailPage extends StatefulWidget {
  final UserModel user;

  const PlantDetailPage({
    super.key,
    required this.user,
  });

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  late TextEditingController _nameController;
  final PlantService _plantService = getIt<PlantService>();
  final UserRepository _userRepository = getIt<UserRepository>();
  final FirebaseAuth _auth = getIt<FirebaseAuth>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.plantName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePlantName() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save plant name'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final plantName = _nameController.text.trim();
      await _userRepository.updatePlantName(
          userId, plantName.isEmpty ? null : plantName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plant name saved!'),
            duration: Duration(seconds: 2),
          ),
        );
        // Dismiss keyboard
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save plant name: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final evolutionStage = _plantService.calculateEvolutionStage(
      widget.user.plantCurrentXp,
    );
    final stageName = _plantService.getEvolutionStageName(evolutionStage);
    final mood = _plantService.getPlantMood(
      widget.user.plantHealth,
      widget.user.currentStreak,
    );
    final growthProgress = _plantService.getGrowthProgress(
      widget.user.plantCurrentXp,
      evolutionStage,
    );
    final nextStageXp = _plantService.xpRequiredForNextStage(
      widget.user.plantCurrentXp,
    );
    final motivationalMessage = _plantService.getMotivationalMessage(
      widget.user.plantHealth,
      widget.user.currentStreak,
      evolutionStage,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Plant Companion'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Avatar
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradientLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: CustomPlantWidget(
                  evolutionStage: evolutionStage,
                  size: 200,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Plant Name Section
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Plant Name',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter a name for your plant',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _isSaving
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.check_rounded),
                              onPressed: _savePlantName,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Plant Stats
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plant Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    context,
                    icon: Icons.eco_rounded,
                    label: 'Evolution Stage',
                    value: 'Stage $evolutionStage - $stageName',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.stars_rounded,
                    label: 'Plant XP',
                    value: '${widget.user.plantCurrentXp} XP',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.trending_up_rounded,
                    label: 'Growth Progress',
                    value: '${(growthProgress * 100).toStringAsFixed(0)}%',
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.favorite_rounded,
                    label: 'Health',
                    value: '${widget.user.plantHealth}%',
                    valueColor: _getHealthColor(widget.user.plantHealth),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.mood_rounded,
                    label: 'Mood',
                    value: '${mood.emoji} ${mood.description}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress to Next Stage
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress to Next Stage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: growthProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    evolutionStage >= 5
                        ? 'Maximum evolution reached! 🌳'
                        : '${nextStageXp} XP needed for next stage',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Motivational Message
            PremiumCard(
              padding: const EdgeInsets.all(20),
              gradient: AppColors.primaryGradientLight,
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      motivationalMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Color _getHealthColor(int health) {
    if (health > 70) return Colors.green;
    if (health > 30) return Colors.orange;
    return Colors.red;
  }
}

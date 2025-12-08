// lib/features/home/widgets/plant_evolution_dialog.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/image_with_fallback.dart';
import 'package:fitquest/core/utils/image_url_helper.dart';
import 'package:fitquest/shared/services/plant_service.dart';
import 'package:fitquest/core/di/injection.dart';

class PlantEvolutionDialog extends StatefulWidget {
  final int oldStage;
  final int newStage;
  final String plantName;

  const PlantEvolutionDialog({
    super.key,
    required this.oldStage,
    required this.newStage,
    required this.plantName,
  });

  @override
  State<PlantEvolutionDialog> createState() => _PlantEvolutionDialogState();
}

class _PlantEvolutionDialogState extends State<PlantEvolutionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    _controller.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantService = getIt<PlantService>();
    final oldStageName = plantService.getEvolutionStageName(widget.oldStage);
    final newStageName = plantService.getEvolutionStageName(widget.newStage);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.5708, // Down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.lightGreen,
                Colors.white,
                Colors.yellow,
                Colors.orange,
              ],
            ),
          ),
          // Dialog content
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppBorderRadius.allXL,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration icon
                    const Icon(
                      Icons.celebration_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      '🎉 Evolution! 🎉',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Plant images comparison
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Old stage
                        Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ImageWithFallback(
                                imageUrl: ImageUrlHelper.getPlantImageUrl(
                                    widget.oldStage),
                                assetPath: _getPlantImagePath(widget.oldStage),
                                fallbackIcon: Icons.eco_rounded,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                iconColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              oldStageName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        // New stage
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ImageWithFallback(
                                imageUrl: ImageUrlHelper.getPlantImageUrl(
                                    widget.newStage),
                                assetPath: _getPlantImagePath(widget.newStage),
                                fallbackIcon: Icons.eco_rounded,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                iconColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              newStageName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Message
                    Text(
                      '${widget.plantName} has evolved into a $newStageName!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Close button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlantImagePath(int evolutionStage) {
    if (evolutionStage <= 1) {
      return 'assets/images/companion/seed.png';
    } else if (evolutionStage <= 2) {
      return 'assets/images/companion/sprout.png';
    } else if (evolutionStage <= 3) {
      return 'assets/images/companion/sapling.png';
    } else if (evolutionStage <= 4) {
      return 'assets/images/companion/tree.png';
    } else {
      return 'assets/images/companion/ancient_tree.png';
    }
  }
}


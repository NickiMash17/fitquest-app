// lib/features/home/widgets/plant_companion_card.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/animated_counter.dart';
import 'package:fitquest/shared/widgets/image_with_fallback.dart';
import 'package:fitquest/core/utils/image_url_helper.dart';

class PlantCompanionCard extends StatefulWidget {
  final String plantName;
  final int evolutionStage;
  final int currentXp;
  final int requiredXp;
  final int health;

  const PlantCompanionCard({
    super.key,
    required this.plantName,
    required this.evolutionStage,
    required this.currentXp,
    required this.requiredXp,
    required this.health,
  });

  @override
  State<PlantCompanionCard> createState() => _PlantCompanionCardState();
}

class _PlantCompanionCardState extends State<PlantCompanionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    final progress = widget.requiredXp > 0
        ? (widget.currentXp / widget.requiredXp).clamp(0.0, 1.0)
        : 0.0;
    _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: PremiumCard(
        padding: const EdgeInsets.all(24.0),
        gradient: AppColors.primaryGradientLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Transform.rotate(
                        angle: (1 - value) * 0.1,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: AppBorderRadius.allMD,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.white.withValues(alpha: 0.2 * value),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => _showPlantDetails(context),
                            onDoubleTap: () => _celebratePlant(context),
                            child: ImageWithFallback(
                              imageUrl: ImageUrlHelper.getPlantImageUrl(
                                  widget.evolutionStage),
                              assetPath:
                                  _getPlantImagePath(widget.evolutionStage),
                              fallbackIcon: Icons.eco_rounded,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              iconColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your ${widget.plantName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppBorderRadius.allSM,
                        ),
                        child: Text(
                          'Evolution Stage ${widget.evolutionStage}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Animated progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppBorderRadius.allRound,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFE8F5E9)],
                        ),
                        borderRadius: AppBorderRadius.allRound,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    AnimatedCounter(
                      value: widget.currentXp,
                      textStyle:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                      suffix: ' / ${widget.requiredXp} XP',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      widget.health > 70
                          ? Icons.favorite_rounded
                          : widget.health > 30
                              ? Icons.favorite_border_rounded
                              : Icons.heart_broken_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.health}% Health',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPlantImagePath(int evolutionStage) {
    // Map evolution stages to plant images
    // Stage 0-1: Seed, Stage 2-3: Sprout, Stage 4-5: Sapling, Stage 6+: Tree
    if (evolutionStage <= 1) {
      return 'assets/images/companion/seed.png';
    } else if (evolutionStage <= 3) {
      return 'assets/images/companion/sprout.png';
    } else if (evolutionStage <= 5) {
      return 'assets/images/companion/sapling.png';
    } else {
      return 'assets/images/companion/tree.png';
    }
  }

  void _showPlantDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageWithFallback(
                    imageUrl:
                        ImageUrlHelper.getPlantImageUrl(widget.evolutionStage),
                    assetPath: _getPlantImagePath(widget.evolutionStage),
                    fallbackIcon: Icons.eco_rounded,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.1),
                    iconColor: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.plantName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evolution Stage ${widget.evolutionStage}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    context,
                    icon: Icons.stars_rounded,
                    label: 'Current XP',
                    value: '${widget.currentXp} / ${widget.requiredXp}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.favorite_rounded,
                    label: 'Health',
                    value: '${widget.health}%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _celebratePlant(BuildContext context) {
    // Show celebration animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('${widget.plantName} is growing strong! 🌱'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

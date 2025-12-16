// lib/features/home/widgets/enhanced_plant_card.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';
import 'package:fitquest/shared/widgets/animated_counter.dart';
import 'package:fitquest/shared/widgets/animated_progress_bar.dart';
import 'package:fitquest/shared/widgets/custom_plant_widget.dart';
import 'package:fitquest/shared/services/plant_service.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/widgets/tree_sway_animation.dart';
import 'package:fitquest/shared/widgets/golden_fruit.dart';
import 'package:fitquest/shared/widgets/sparkle_effect.dart';
import 'package:fitquest/shared/widgets/tree_sparkle_particles.dart';
import 'package:fitquest/shared/widgets/tree_shake_interaction.dart';
import 'package:fitquest/shared/widgets/leaf_fall_particles.dart';
import 'package:fitquest/shared/widgets/enhanced_tree_sway.dart';
import 'package:fitquest/core/constants/app_typography.dart';

// Import FloatingLeavesBackground from tree_sway_animation.dart
// (it's in the same file)

class EnhancedPlantCard extends StatefulWidget {
  final String plantName;
  final int evolutionStage;
  final int currentXp;
  final int requiredXp;
  final int health;
  final int streak;
  final int? userLevel; // User level for golden fruit (level 36+)
  final DateTime? lastActivityDate;
  final int? xpGained; // XP gained from last activity (for animation)
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const EnhancedPlantCard({
    super.key,
    required this.plantName,
    required this.evolutionStage,
    required this.currentXp,
    required this.requiredXp,
    required this.health,
    required this.streak,
    this.userLevel,
    this.lastActivityDate,
    this.xpGained,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<EnhancedPlantCard> createState() => _EnhancedPlantCardState();
}

class _EnhancedPlantCardState extends State<EnhancedPlantCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _xpAnimationController;
  late AnimationController _celebrationController;
  late ConfettiController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _xpGainAnimation;
  late Animation<Offset> _xpTextAnimation;

  int _previousStage = 0;
  bool _showEvolutionCelebration = false;

  @override
  void initState() {
    super.initState();
    _previousStage = widget.evolutionStage;

    // Scale animation for plant appearance
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Pulse animation for plant breathing effect - more visible
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // XP gain animation
    _xpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Celebration animation for evolution
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    // More visible pulse animation (1.0 to 1.08 = 8% scale change)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    final progress = widget.requiredXp > 0
        ? (widget.currentXp / widget.requiredXp).clamp(0.0, 1.0)
        : 0.0;
    _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _xpGainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _xpAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _xpTextAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.5)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -0.5), end: const Offset(0, -1)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _xpAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleController.forward();

    // Check for evolution
    if (widget.evolutionStage > _previousStage) {
      _triggerEvolutionCelebration();
    }

    // Trigger XP gain animation if XP was gained
    if (widget.xpGained != null && widget.xpGained! > 0) {
      _triggerXpGainAnimation();
    }
  }

  @override
  void didUpdateWidget(EnhancedPlantCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for evolution
    if (widget.evolutionStage > oldWidget.evolutionStage) {
      _triggerEvolutionCelebration();
    }

    // Trigger XP gain animation if XP was gained
    if (widget.xpGained != null &&
        widget.xpGained! > 0 &&
        (oldWidget.xpGained == null || oldWidget.xpGained == 0)) {
      _triggerXpGainAnimation();
    }

    // Update progress animation
    final progress = widget.requiredXp > 0
        ? (widget.currentXp / widget.requiredXp).clamp(0.0, 1.0)
        : 0.0;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: progress,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleController.forward(from: 0.0);
  }

  void _triggerEvolutionCelebration() {
    setState(() {
      _showEvolutionCelebration = true;
    });
    _confettiController.play();
    _celebrationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showEvolutionCelebration = false;
          });
        }
      });
    });
  }

  void _triggerXpGainAnimation() {
    _xpAnimationController.reset();
    _xpAnimationController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _xpAnimationController.dispose();
    _celebrationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Cache PlantService to avoid repeated lookups
  static PlantService? _cachedPlantService;

  @override
  Widget build(BuildContext context) {
    // Get PlantService from dependency injection (cached)
    PlantService plantService;
    try {
      plantService = _cachedPlantService ??= getIt<PlantService>();
    } catch (e) {
      // Return a simple error widget without debugPrint in production
      return Container(
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Plant Card Error'),
          ],
        ),
      );
    }

    final mood = plantService.getPlantMood(widget.health, widget.streak);

    return RepaintBoundary(
      child: _buildPlantCard(plantService, mood),
    );
  }

  Widget _buildPlantCard(PlantService plantService, PlantMood mood) {
    final stackChildren = <Widget>[
      ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onDoubleTap: widget.onDoubleTap,
          child: PremiumCard(
            padding: const EdgeInsets.all(24.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryDark,
                AppColors.primaryGreen.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            onTap: widget.onTap,
            showShadow: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Plant Avatar with pulse animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              widget.onTap?.call();
                              // Navigate to plant detail page
                              // This will be handled by the parent widget
                            },
                            onDoubleTap: widget.onDoubleTap,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: AppBorderRadius.allMD,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Sparkle particles around tree
                                  Positioned.fill(
                                    child: TreeSparkleParticles(
                                      treeSize: 120,
                                      particleCount: 8,
                                      active: widget.evolutionStage >= 3,
                                    ),
                                  ),
                                  // Enhanced tree sway with wind strength
                                  TreeShakeInteraction(
                                    onShake: () {
                                      // Trigger leaf fall particles
                                      final RenderBox? renderBox = context
                                          .findRenderObject() as RenderBox?;
                                      if (renderBox != null) {
                                        final position = renderBox
                                            .localToGlobal(Offset.zero);
                                        LeafFallParticles.show(
                                          context,
                                          Offset(
                                            position.dx + 60,
                                            position.dy + 60,
                                          ),
                                          leafCount: 5,
                                        );
                                      }
                                    },
                                    child: EnhancedTreeSway(
                                      windStrength: widget.streak > 7
                                          ? 0.8
                                          : widget.streak > 3
                                              ? 0.5
                                              : 0.3,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: AppBorderRadius.allLG,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 25,
                                              spreadRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: AppBorderRadius.allLG,
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  AppBorderRadius.allLG,
                                            ),
                                            child: CustomPlantWidget(
                                              evolutionStage:
                                                  widget.evolutionStage,
                                              size: 120,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Mood indicator
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        mood.emoji,
                                        style: AppTypography.bodyLarge
                                            .copyWith(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  // Golden fruit for majestic trees (level 36+)
                                  if (widget.userLevel != null &&
                                      widget.userLevel! >= 36)
                                    Positioned(
                                      top: -10,
                                      left: 20,
                                      child: SparkleEffect(
                                        active: true,
                                        sparkleColor: AppColors.xpGold,
                                        child: const GoldenFruit(size: 25),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plantName.isNotEmpty
                                ? widget.plantName
                                : plantService.getEvolutionStageName(
                                    widget.evolutionStage,
                                  ),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Stage ${widget.evolutionStage}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mood.emoji,
                                  style: AppTypography.labelMedium
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Enhanced Growth Progress Bar
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedProgressBar(
                      progress: widget.requiredXp > 0
                          ? (widget.currentXp / widget.requiredXp)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      height: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      progressGradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFE8F5E9),
                        ],
                      ),
                      showGlow: true,
                      animationDuration: const Duration(milliseconds: 1000),
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
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
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
                              color: _getHealthColor(widget.health),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.health}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
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
              ],
            ),
          ),
        ),
      ),
    ];

    // Add XP Gain Animation Overlay if needed
    if (widget.xpGained != null && widget.xpGained! > 0) {
      stackChildren.add(
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _xpTextAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _xpTextAnimation.value.dy * 50,
                  ),
                  child: Opacity(
                    opacity: 1 - _xpGainAnimation.value,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.9),
                          borderRadius: AppBorderRadius.allXL,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.xpGained} XP',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Add confetti for evolution celebration
    if (_showEvolutionCelebration) {
      stackChildren.add(
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.5708, // Down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.lightGreen,
                Colors.white,
                Colors.yellow,
              ],
            ),
          ),
        ),
      );
    }

    // Wrap in FloatingLeavesBackground for ambient effect - more visible
    return FloatingLeavesBackground(
      leafCount: 10, // More leaves for better visibility
      child: Stack(
        clipBehavior: Clip.none,
        children: stackChildren,
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health > 70) return Colors.green;
    if (health > 30) return Colors.orange;
    return Colors.red;
  }
}

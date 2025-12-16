// lib/shared/widgets/premium_avatar.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/shared/models/user_model.dart';
// custom_plant_widget moved to PlantAvatar usage
import 'package:fitquest/shared/widgets/plant_avatar.dart';
import 'package:fitquest/core/constants/app_typography.dart';

/// Premium avatar widget with level-based styling and achievements
class PremiumAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final bool showBadge;
  final bool showLevelRing;
  final bool usePlantAvatar;
  final VoidCallback? onTap;

  const PremiumAvatar({
    super.key,
    required this.user,
    this.size = 64,
    this.showBadge = true,
    this.showLevelRing = true,
    this.usePlantAvatar = false,
    this.onTap,
  });

  Gradient _getAvatarGradient() {
    final level = user.currentLevel;
    final streak = user.currentStreak;

    // Level-based gradients
    if (level >= 20) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)], // Gold
      );
    } else if (level >= 15) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)], // Purple
      );
    } else if (level >= 10) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)], // Blue
      );
    } else if (level >= 5) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B35), Color(0xFFFF4500)], // Orange
      );
    } else if (streak >= 7) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Green
      );
    }

    // Default gradient
    return AppColors.primaryGradient;
  }

  Color _getRingColor() {
    final level = user.currentLevel;
    if (level >= 20) return const Color(0xFFFFD700);
    if (level >= 15) return const Color(0xFF9C27B0);
    if (level >= 10) return const Color(0xFF2196F3);
    if (level >= 5) return const Color(0xFFFF6B35);
    return AppColors.primaryGreen;
  }

  Widget? _getBadgeIcon() {
    final streak = user.currentStreak;
    final level = user.currentLevel;

    if (streak >= 30) {
      return const Icon(
        Icons.local_fire_department_rounded,
        color: Colors.white,
        size: 16,
      );
    } else if (streak >= 7) {
      return const Icon(
        Icons.emoji_events_rounded,
        color: Colors.white,
        size: 16,
      );
    } else if (level >= 10) {
      return const Icon(Icons.star_rounded, color: Colors.white, size: 16);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer glow ring
          Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getRingColor().withValues(alpha: 0.3),
                  _getRingColor().withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Level ring (if enabled)
          if (showLevelRing && user.currentLevel > 0)
            Positioned(
              left: -2,
              top: -2,
              child: Container(
                width: size + 4,
                height: size + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRingColor(),
                    width: 2.5,
                  ),
                ),
              ),
            ),
          // Main avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: size * 0.05,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRingColor().withValues(alpha: 0.4),
                  blurRadius: size * 0.3,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.05),
                ),
              ],
              image: user.photoUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(user.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: user.photoUrl == null ? _getAvatarGradient() : null,
            ),
            child: user.photoUrl == null && !usePlantAvatar
                ? Center(
                    child: Text(
                      user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : user.photoUrl == null && usePlantAvatar
                    ? Center(
                        child: SizedBox(
                          width: size * 0.9,
                          height: size * 0.9,
                          child: PlantAvatar(
                            evolutionStage: user.plantEvolutionStage,
                            size: size * 0.9,
                            showRing: true,
                            onTap: onTap,
                            badge: _getBadgeIcon(),
                          ),
                        ),
                      )
                    : null,
          ),
          // Achievement badge
          if (showBadge && _getBadgeIcon() != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getRingColor(),
                      _getRingColor().withValues(alpha: 0.8),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getRingColor().withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: _getBadgeIcon(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated premium avatar with pulse effect
class AnimatedPremiumAvatar extends StatefulWidget {
  final UserModel user;
  final double size;
  final bool showBadge;
  final bool showLevelRing;
  final bool usePlantAvatar;
  final VoidCallback? onTap;

  const AnimatedPremiumAvatar({
    super.key,
    required this.user,
    this.size = 64,
    this.showBadge = true,
    this.showLevelRing = true,
    this.onTap,
    this.usePlantAvatar = false,
  });

  @override
  State<AnimatedPremiumAvatar> createState() => _AnimatedPremiumAvatarState();
}

class _AnimatedPremiumAvatarState extends State<AnimatedPremiumAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationAnimation,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: PremiumAvatar(
          user: widget.user,
          size: widget.size,
          showBadge: widget.showBadge,
          showLevelRing: widget.showLevelRing,
          usePlantAvatar: widget.usePlantAvatar,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

// lib/shared/widgets/plant_avatar.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
// AppTypography not used here
import 'package:fitquest/shared/widgets/custom_plant_widget.dart';

/// PlantAvatar - stylized plant avatar used for gamified UX
class PlantAvatar extends StatelessWidget {
  final int evolutionStage;
  final double size;
  final bool showRing;
  final Color? ringColor;
  final VoidCallback? onTap;
  final Widget? badge;

  const PlantAvatar({
    super.key,
    required this.evolutionStage,
    this.size = 64,
    this.showRing = true,
    this.ringColor,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = ringColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        if (showRing)
          Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.0)
                ],
              ),
            ),
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
            ],
          ),
          child: ClipOval(
              child: CustomPlantWidget(
                  evolutionStage: evolutionStage, size: size)),
        ),
        if (badge != null) Positioned(right: -4, bottom: -4, child: badge!),
      ]),
    );
  }
}

// lib/features/home/widgets/quick_actions_section.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_shadows.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/shared/models/activity_model.dart';
import 'package:fitquest/shared/widgets/image_with_fallback.dart';
import 'package:fitquest/core/utils/activity_image_helper.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _buildActionItem(
        context,
        icon: Icons.directions_run_rounded,
        label: 'Workout',
        gradient: AppColors.purpleGradient,
        activityType: ActivityType.exercise,
      ),
      _buildActionItem(
        context,
        icon: Icons.self_improvement_rounded,
        label: 'Meditate',
        gradient: AppColors.blueGradient,
        activityType: ActivityType.meditation,
      ),
      _buildActionItem(
        context,
        icon: Icons.water_drop_rounded,
        label: 'Hydrate',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03A9F4), Color(0xFF0288D1)],
        ),
        activityType: ActivityType.hydration,
      ),
      _buildActionItem(
        context,
        icon: Icons.nightlight_round_rounded,
        label: 'Sleep',
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
        ),
        activityType: ActivityType.sleep,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: actions,
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    ActivityType? activityType,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackService.lightImpact();
          Navigator.of(context).pushNamed(
            AppRouter.addActivity,
            arguments: activityType,
          );
        },
        borderRadius: AppBorderRadius.allLG,
        child: Semantics(
          label: 'Quick action: $label',
          button: true,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: AppBorderRadius.allLG,
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: activityType != null
                        ? ImageWithFallback(
                            imageUrl:
                                ActivityImageHelper.getQuickActionImageUrl(
                                    activityType),
                            assetPath:
                                ActivityImageHelper.getQuickActionImagePath(
                                    activityType),
                            fallbackIcon: ActivityImageHelper.getActivityIcon(
                                activityType),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            iconColor: Colors.white,
                          )
                        : Icon(icon, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

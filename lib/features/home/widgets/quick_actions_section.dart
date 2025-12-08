// lib/features/home/widgets/quick_actions_section.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
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
    return _AnimatedActionButton(
      gradient: gradient,
      onTap: () {
        HapticFeedbackService.lightImpact();
        Navigator.of(context).pushNamed(
          AppRouter.addActivity,
          arguments: activityType,
        );
      },
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: activityType != null
                  ? ImageWithFallback(
                      imageUrl: ActivityImageHelper.getQuickActionImageUrl(
                          activityType),
                      assetPath: ActivityImageHelper.getQuickActionImagePath(
                          activityType),
                      fallbackIcon:
                          ActivityImageHelper.getActivityIcon(activityType),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                  letterSpacing: 0.2,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final Gradient gradient;
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedActionButton({
    required this.gradient,
    required this.onTap,
    required this.child,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quick action',
      button: true,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: AppBorderRadius.allLG,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null, // Handled by GestureDetector
                borderRadius: AppBorderRadius.allLG,
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

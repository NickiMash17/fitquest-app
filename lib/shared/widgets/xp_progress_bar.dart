// lib/shared/widgets/xp_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Enhanced XP progress bar with moving shine effect and glow
/// Phase 2: XP bar shine effect
class XpProgressBar extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final int? currentXp;
  final int? requiredXp;
  final Duration animationDuration;

  const XpProgressBar({
    super.key,
    required this.progress,
    this.height = 20.0,
    this.currentXp,
    this.requiredXp,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shineController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Progress fill animation
    _progressController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Continuous shine animation
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _progressController.forward();
  }

  @override
  void didUpdateWidget(XpProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeOutCubic,
        ),
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with tick marks
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.2),
            borderRadius: AppBorderRadius.allRound,
          ),
        ),

        // Animated fill
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientXp,
                  borderRadius: AppBorderRadius.allRound,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.xp.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Moving shine effect
        AnimatedBuilder(
          animation: _shineController,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(_shineController.value * 2 - 1, 0),
                    end: Alignment(_shineController.value * 2, 0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: AppBorderRadius.allRound,
                ),
              ),
            );
          },
        ),

        // Glow at the end of progress
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            if (_progressAnimation.value <= 0) return const SizedBox.shrink();
            return Positioned(
              left: MediaQuery.of(context).size.width * _progressAnimation.value - 10,
              child: Container(
                width: 20,
                height: widget.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.xp.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // XP text overlay (optional)
        if (widget.currentXp != null && widget.requiredXp != null)
          Center(
            child: Text(
              '${widget.currentXp} / ${widget.requiredXp} XP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}


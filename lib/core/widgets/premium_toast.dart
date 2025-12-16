// lib/core/widgets/premium_toast.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_dimensions.dart';
import 'package:fitquest/core/constants/app_durations.dart';
import 'package:fitquest/core/services/haptic_service.dart';

/// Premium toast notification with smooth animations
class PremiumToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
    bool showProgress = true,
  }) {
    HapticService.light();
    
    final overlay = Overlay.of(context);
    final overlayEntry = _PremiumToastOverlay(
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      duration: duration,
      showProgress: showProgress,
    );

    overlay.insert(overlayEntry);
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.success,
      iconColor: Colors.white,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.error,
      iconColor: Colors.white,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppColors.info,
      iconColor: Colors.white,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppColors.warning,
      iconColor: Colors.white,
    );
  }
}

class _PremiumToastOverlay extends OverlayEntry {
  _PremiumToastOverlay({
    required this.message,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    required this.duration,
    this.showProgress = true,
  }) : super(
          builder: (context) => _PremiumToastWidget(
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            iconColor: iconColor,
            duration: duration,
            showProgress: showProgress,
            onDismiss: () {
              // Overlay will be removed automatically
            },
          ),
        );
  
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Duration duration;
  final bool showProgress;
}

class _PremiumToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Duration duration;
  final bool showProgress;
  final VoidCallback onDismiss;

  const _PremiumToastWidget({
    required this.message,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    required this.duration,
    this.showProgress = true,
    required this.onDismiss,
  });

  @override
  State<_PremiumToastWidget> createState() => _PremiumToastWidgetState();
}

class _PremiumToastWidgetState extends State<_PremiumToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: AppDurations.moderate,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.forward();
    _progressController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final iconColor = widget.iconColor ?? Colors.white;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: iconColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.showProgress) ...[
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: 1.0 - _progressController.value,
                          backgroundColor: iconColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                          minHeight: 2,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


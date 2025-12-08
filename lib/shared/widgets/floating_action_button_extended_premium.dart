// lib/shared/widgets/floating_action_button_extended_premium.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Premium floating action button with enhanced animations
class PremiumFloatingActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;

  const PremiumFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
  });

  @override
  State<PremiumFloatingActionButton> createState() =>
      _PremiumFloatingActionButtonState();
}

class _PremiumFloatingActionButtonState
    extends State<PremiumFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    final gradient = widget.gradient ?? AppColors.primaryGradient;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppBorderRadius.allLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen
                    .withValues(alpha: 0.5 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                offset: Offset(0, 8 * _glowAnimation.value),
                spreadRadius: 3 * _glowAnimation.value,
              ),
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FloatingActionButton.extended(
              onPressed: widget.isLoading ? null : widget.onPressed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(widget.icon, color: Colors.white),
              label: Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


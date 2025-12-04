// lib/shared/widgets/premium_button.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_colors.dart';

/// Premium button with gradient and animations
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool isOutlined;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.isOutlined = false,
    this.width,
    this.height = 52,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : (widget.gradient ?? AppColors.primaryGradient),
            color: widget.isOutlined
                ? Colors.transparent
                : (widget.backgroundColor ?? AppColors.primaryGreen),
            borderRadius: AppBorderRadius.allMD,
            border: widget.isOutlined
                ? Border.all(
                    color: widget.backgroundColor ?? AppColors.primaryGreen,
                    width: 2,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isOutlined
                          ? (widget.backgroundColor ?? AppColors.primaryGreen)
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isOutlined
                          ? (widget.backgroundColor ?? AppColors.primaryGreen)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

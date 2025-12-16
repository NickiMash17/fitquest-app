// lib/shared/widgets/enhanced_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
// font usage via AppTypography
import 'package:fitquest/core/constants/app_typography.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';

/// Enhanced bottom navigation with morphing background indicator
/// Phase 4: Enhanced bottom navigation
class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationItem> items;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<EnhancedBottomNavigation> createState() =>
      _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    );
    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(EnhancedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorController.reset();
      _indicatorController.forward();
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            children: [
              // Morphing background indicator
              AnimatedBuilder(
                animation: _indicatorAnimation,
                builder: (context, child) {
                  final itemWidth =
                      MediaQuery.of(context).size.width / widget.items.length;
                  final indicatorLeft = widget.currentIndex * itemWidth + 8;
                  final indicatorWidth = itemWidth - 16;

                  return Positioned(
                    left: indicatorLeft,
                    top: 8,
                    width: indicatorWidth,
                    height: 54,
                    child: Transform.scale(
                      scale: 0.9 + (_indicatorAnimation.value * 0.1),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppBorderRadius.allLG,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Navigation items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index != widget.currentIndex) {
                          HapticFeedbackService.selectionClick();
                          widget.onTap(index);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: AppBorderRadius.allMD,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.transparent,
                              ),
                              child: Icon(
                                isSelected
                                    ? item.activeIcon
                                    : item.inactiveIcon,
                                size: isSelected ? 28 : 24,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: AppTypography.labelMedium.copyWith(
                                fontSize: isSelected ? 12 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                letterSpacing: isSelected ? 0.2 : 0,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation item model
class BottomNavigationItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const BottomNavigationItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

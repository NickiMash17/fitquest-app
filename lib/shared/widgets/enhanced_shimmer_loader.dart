// lib/shared/widgets/enhanced_shimmer_loader.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Enhanced shimmer loader with gradient animation
/// Phase 4: Enhanced shimmer loading states
class EnhancedShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final Gradient? shimmerGradient;

  const EnhancedShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
    this.shimmerGradient,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceVariant =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final gradient = shimmerGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceVariant.withValues(alpha: 0.3),
            surfaceVariant.withValues(alpha: 0.6),
            surfaceVariant.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        );

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorderRadius.allMD,
        color: surfaceVariant.withValues(alpha: 0.2),
      ),
      child: Shimmer.fromColors(
        baseColor: surfaceVariant.withValues(alpha: 0.2),
        highlightColor: surfaceVariant.withValues(alpha: 0.8),
        period: const Duration(milliseconds: 1500),
        direction: ShimmerDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? AppBorderRadius.allMD,
            gradient: gradient,
          ),
        ),
      ),
    );
  }
}

/// Enhanced skeleton card with glassmorphism effect
class EnhancedSkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const EnhancedSkeletonCard({
    super.key,
    this.height,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      child: EnhancedShimmerLoader(
        width: double.infinity,
        height: height ?? 120,
        borderRadius: AppBorderRadius.allLG,
      ),
    );
  }
}

/// Enhanced skeleton list item with avatar and text
class EnhancedSkeletonListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;

  const EnhancedSkeletonListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showAvatar) ...[
            const EnhancedShimmerLoader(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EnhancedShimmerLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  const EnhancedShimmerLoader(
                    width: 150,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16),
            const EnhancedShimmerLoader(
              width: 24,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Enhanced skeleton stats row with glassmorphism
class EnhancedSkeletonStatsRow extends StatelessWidget {
  final int itemCount;

  const EnhancedSkeletonStatsRow({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        itemCount,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == itemCount - 1 ? 0 : 8,
            ),
            child: const Column(
              children: [
                EnhancedShimmerLoader(
                  width: double.infinity,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(height: 8),
                EnhancedShimmerLoader(
                  width: 80,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 4),
                EnhancedShimmerLoader(
                  width: 60,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


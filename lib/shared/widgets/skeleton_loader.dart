import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Skeleton loader widget with shimmer effect
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceVariant =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorderRadius.allMD,
        color: surfaceVariant.withValues(alpha: 0.5),
      ),
      child: Shimmer.fromColors(
        baseColor: surfaceVariant.withValues(alpha: 0.3),
        highlightColor: surfaceVariant.withValues(alpha: 0.8),
        period: const Duration(milliseconds: 1200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? AppBorderRadius.allMD,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

/// Skeleton card loader
class SkeletonCard extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const SkeletonCard({
    super.key,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      height: height ?? 120,
      child: SkeletonLoader(
        width: double.infinity,
        height: height ?? 120,
        borderRadius: AppBorderRadius.allLG,
      ),
    );
  }
}

/// Skeleton list item loader
class SkeletonListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;

  const SkeletonListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showAvatar) ...[
            const SkeletonLoader(
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
                const SkeletonLoader(width: double.infinity, height: 16),
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: 150, height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton stats row
class SkeletonStatsRow extends StatelessWidget {
  const SkeletonStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == 2 ? 0 : 8,
            ),
            child: const Column(
              children: [
                SkeletonLoader(width: double.infinity, height: 60),
                SizedBox(height: 8),
                SkeletonLoader(width: 80, height: 14),
                SizedBox(height: 4),
                SkeletonLoader(width: 60, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

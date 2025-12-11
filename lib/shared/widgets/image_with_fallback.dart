// lib/shared/widgets/image_with_fallback.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Widget that displays an image with icon fallback when image is missing
class ImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final IconData fallbackIcon;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? iconColor;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;

  const ImageWithFallback({
    super.key,
    this.imageUrl,
    this.assetPath,
    required this.fallbackIcon,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconColor,
    this.backgroundColor,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final borderRadius = this.borderRadius ?? AppBorderRadius.allMD;
      final iconColor =
          this.iconColor ?? Theme.of(context).colorScheme.onSurface;
      final backgroundColor = this.backgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest;

      Widget imageWidget;

      // Prioritize network image if available, then asset, then icon fallback
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        // Try network image first, fallback to icon on error
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildShimmer(context),
          errorWidget: (context, url, error) {
            // If network fails, show icon fallback
            return _buildIconFallback(
              context,
              fallbackIcon,
              iconColor,
              backgroundColor,
              backgroundGradient,
            );
          },
          fadeInDuration: const Duration(milliseconds: 300),
        );
      } else {
        // No image source available, show icon fallback
        imageWidget = _buildIconFallback(
          context,
          fallbackIcon,
          iconColor,
          backgroundColor,
          backgroundGradient,
        );
      }

      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    } catch (e) {
      // If anything goes wrong, show icon fallback
      debugPrint('ImageWithFallback error: $e');
      try {
        final safeIconColor =
            this.iconColor ?? Theme.of(context).colorScheme.onSurface;
        final safeBackgroundColor = this.backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest;
        return _buildIconFallback(
          context,
          fallbackIcon,
          safeIconColor,
          safeBackgroundColor,
          backgroundGradient,
        );
      } catch (e2) {
        // Last resort - simple icon
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(fallbackIcon, size: 24, color: Colors.grey[600]),
        );
      }
    }
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius ?? AppBorderRadius.allMD,
        ),
      ),
    );
  }

  Widget _buildIconFallback(
    BuildContext context,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    Gradient? gradient,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: borderRadius ?? AppBorderRadius.allMD,
      ),
      child: Icon(
        icon,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 48,
        color: iconColor,
      ),
    );
  }
}

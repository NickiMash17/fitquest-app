// lib/shared/widgets/interactive_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';

/// Premium interactive image widget with hero animations, shimmer loading,
/// and gesture interactions
class InteractiveImage extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final String? placeholderAssetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool enableHero;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final Widget? errorWidget;
  final Widget? placeholderWidget;

  const InteractiveImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.placeholderAssetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enableHero = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.errorWidget,
    this.placeholderWidget,
  }) : assert(
          imageUrl != null || assetPath != null,
          'Either imageUrl or assetPath must be provided',
        );

  @override
  State<InteractiveImage> createState() => _InteractiveImageState();
}

class _InteractiveImageState extends State<InteractiveImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  Widget _buildImage() {
    final borderRadius = widget.borderRadius ?? AppBorderRadius.allMD;
    final imageWidget = widget.imageUrl != null
        ? _buildNetworkImage()
        : _buildAssetImage();

    Widget result = ClipRRect(
      borderRadius: borderRadius,
      child: imageWidget,
    );

    // Add hero animation if enabled
    if (widget.enableHero && widget.heroTag != null) {
      result = Hero(
        tag: widget.heroTag!,
        child: result,
      );
    }

    // Add gesture detection
    if (widget.onTap != null || widget.onLongPress != null || widget.onDoubleTap != null) {
      result = GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: result,
        ),
      );
    }

    return result;
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) =>
          widget.errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      widget.assetPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        // Try placeholder if available, otherwise show error widget
        if (widget.placeholderAssetPath != null) {
          return Image.asset(
            widget.placeholderAssetPath!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) =>
                widget.errorWidget ?? _buildErrorWidget(),
          );
        }
        return widget.errorWidget ?? _buildErrorWidget();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null
              ? child
              : widget.placeholderWidget ?? _buildShimmer(),
        );
      },
    );
  }

  Widget _buildShimmer() {
    final baseColor = widget.shimmerBaseColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = widget.shimmerHighlightColor ??
        Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: widget.borderRadius ?? AppBorderRadius.allMD,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: widget.borderRadius ?? AppBorderRadius.allMD,
      ),
      child: Icon(
        Icons.image_not_supported_rounded,
        size: (widget.width != null && widget.height != null)
            ? (widget.width! < widget.height! ? widget.width! * 0.4 : widget.height! * 0.4)
            : 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }
}

/// Image gallery widget for displaying multiple images with swipe gestures
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTagPrefix;
  final Function(int)? onPageChanged;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTagPrefix,
    this.onPageChanged,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                heroTag: widget.heroTagPrefix != null
                    ? '${widget.heroTagPrefix}_$index'
                    : null,
                borderRadius: AppBorderRadius.allLG,
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


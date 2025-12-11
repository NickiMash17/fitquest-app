// lib/shared/widgets/custom_plant_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fitquest/core/constants/app_colors.dart';

/// Custom drawn plant widget that replaces image assets
/// Draws plants for each evolution stage using the design system
/// Optimized with RepaintBoundary to prevent unnecessary repaints
/// Fully accessible with semantic labels
class CustomPlantWidget extends StatelessWidget {
  final int evolutionStage;
  final double size;
  final String? semanticLabel;
  final String? semanticHint;

  const CustomPlantWidget({
    super.key,
    required this.evolutionStage,
    this.size = 120.0,
    this.semanticLabel,
    this.semanticHint,
  });

  String _getStageName(int stage) {
    switch (stage) {
      case 1:
        return 'Seedling';
      case 2:
        return 'Sprout';
      case 3:
        return 'Sapling';
      case 4:
        return 'Young Tree';
      case 5:
        return 'Mature Tree';
      case 6:
        return 'Majestic Tree';
      default:
        return 'Seedling';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stageName = _getStageName(evolutionStage);
    final label = semanticLabel ?? 'Plant companion at $stageName stage';
    final hint = semanticHint ?? 'Double tap to view plant details';

    return RepaintBoundary(
      child: Semantics(
        label: label,
        hint: hint,
        image: true,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _PlantPainter(
              evolutionStage: evolutionStage,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantPainter extends CustomPainter {
  final int evolutionStage;
  final double size;

  // Cached Paint objects to avoid recreation on every paint
  Paint? _cachedSoilPaint;
  Paint? _cachedStemPaint;
  Paint? _cachedLeafPaint;
  Paint? _cachedTrunkPaint;
  Paint? _cachedFruitPaint;
  
  // Cached gradients for expensive operations
  Shader? _cachedYoungTreeGradient;
  Shader? _cachedMatureTreeGradient;
  Shader? _cachedMajesticTreeGradient;
  
  // Track last size to invalidate cache when size changes
  double _lastCachedSize = 0;

  _PlantPainter({
    required this.evolutionStage,
    required this.size,
  });

  /// Initialize cached Paint objects
  void _initializePaints() {
    if (_cachedSoilPaint == null || _lastCachedSize != size) {
      _cachedSoilPaint = Paint()
        ..color = AppColors.treeTrunk
        ..style = PaintingStyle.fill;

      _cachedStemPaint = Paint()
        ..color = AppColors.treeTrunk
        ..style = PaintingStyle.fill
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      _cachedLeafPaint = Paint()
        ..color = AppColors.treeLeaves
        ..style = PaintingStyle.fill;

      _cachedTrunkPaint = Paint()
        ..color = AppColors.treeTrunk
        ..style = PaintingStyle.fill;

      _cachedFruitPaint = Paint()
        ..color = AppColors.xpGold
        ..style = PaintingStyle.fill;

      _lastCachedSize = size;
    }
  }

  /// Initialize cached gradients
  void _initializeGradients(double canvasSize) {
    if (_cachedYoungTreeGradient == null || _lastCachedSize != size) {
      _cachedYoungTreeGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.treeLeavesLight,
          AppColors.treeLeaves,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, canvasSize, canvasSize),
      );
    }

    if (_cachedMatureTreeGradient == null || _lastCachedSize != size) {
      _cachedMatureTreeGradient = RadialGradient(
        center: Alignment.topCenter,
        colors: [
          AppColors.treeLeavesLight,
          AppColors.treeLeaves,
          AppColors.treeLeaves.withValues(alpha: 0.8),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, canvasSize, canvasSize),
      );
    }

    if (_cachedMajesticTreeGradient == null || _lastCachedSize != size) {
      _cachedMajesticTreeGradient = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          AppColors.treeLeavesLight,
          AppColors.treeLeaves,
          AppColors.treeLeaves.withValues(alpha: 0.9),
          AppColors.primaryDark,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, canvasSize, canvasSize),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Initialize cached paints and gradients
    _initializePaints();
    _initializeGradients(canvasSize.width);

    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    switch (evolutionStage) {
      case 0:
      case 1:
        _drawSeedling(canvas, centerX, centerY);
        break;
      case 2:
        _drawSprout(canvas, centerX, centerY);
        break;
      case 3:
        _drawSapling(canvas, centerX, centerY);
        break;
      case 4:
        _drawYoungTree(canvas, centerX, centerY, canvasSize.width);
        break;
      case 5:
        _drawMatureTree(canvas, centerX, centerY, canvasSize.width);
        break;
      default:
        _drawMajesticTree(canvas, centerX, centerY, canvasSize.width);
    }
  }

  // Stage 0-1: Seedling - Small green sprout
  void _drawSeedling(Canvas canvas, double centerX, double centerY) {
    _initializePaints();
    
    // Draw soil
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + size * 0.35),
        width: size * 0.6,
        height: size * 0.2,
      ),
      _cachedSoilPaint!,
    );

    // Draw stem
    canvas.drawLine(
      Offset(centerX, centerY + size * 0.25),
      Offset(centerX, centerY - size * 0.1),
      _cachedStemPaint!,
    );

    // Draw two small leaves
    _drawLeaf(canvas, centerX - size * 0.15, centerY - size * 0.15, size * 0.2,
        _cachedLeafPaint!);
    _drawLeaf(canvas, centerX + size * 0.15, centerY - size * 0.15, size * 0.2,
        _cachedLeafPaint!);
  }

  // Stage 2: Sprout - Growing with more leaves
  void _drawSprout(Canvas canvas, double centerX, double centerY) {
    _initializePaints();
    
    final stemPaint = Paint()
      ..color = AppColors.treeTrunk
      ..style = PaintingStyle.fill
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw soil
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + size * 0.35),
        width: size * 0.6,
        height: size * 0.2,
      ),
      _cachedSoilPaint!,
    );

    // Draw stem
    canvas.drawLine(
      Offset(centerX, centerY + size * 0.25),
      Offset(centerX, centerY - size * 0.2),
      stemPaint,
    );

    // Draw multiple leaves
    _drawLeaf(canvas, centerX - size * 0.2, centerY - size * 0.2, size * 0.25,
        _cachedLeafPaint!);
    _drawLeaf(canvas, centerX + size * 0.2, centerY - size * 0.2, size * 0.25,
        _cachedLeafPaint!);
    _drawLeaf(canvas, centerX, centerY - size * 0.3, size * 0.2, _cachedLeafPaint!);
  }

  // Stage 3: Sapling - Small tree with trunk and branches
  void _drawSapling(Canvas canvas, double centerX, double centerY) {
    _initializePaints();
    
    final branchPaint = Paint()
      ..color = AppColors.treeTrunk
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + size * 0.2),
          width: size * 0.15,
          height: size * 0.4,
        ),
        const Radius.circular(4),
      ),
      _cachedTrunkPaint!,
    );

    // Draw branches
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX - size * 0.25, centerY - size * 0.1),
      branchPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX + size * 0.25, centerY - size * 0.1),
      branchPaint,
    );

    // Draw leaf clusters
    _drawLeafCluster(canvas, centerX - size * 0.25, centerY - size * 0.15,
        size * 0.3, _cachedLeafPaint!);
    _drawLeafCluster(canvas, centerX + size * 0.25, centerY - size * 0.15,
        size * 0.3, _cachedLeafPaint!);
    _drawLeafCluster(
        canvas, centerX, centerY - size * 0.25, size * 0.25, _cachedLeafPaint!);
  }

  // Stage 4: Young Tree - Medium tree with fuller canopy
  void _drawYoungTree(Canvas canvas, double centerX, double centerY, double canvasSize) {
    _initializePaints();
    _initializeGradients(canvasSize);
    
    final leafPaint = Paint()
      ..shader = _cachedYoungTreeGradient
      ..style = PaintingStyle.fill;

    // Draw trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + size * 0.25),
          width: size * 0.18,
          height: size * 0.5,
        ),
        const Radius.circular(5),
      ),
      _cachedTrunkPaint!,
    );

    // Draw branches
    _drawBranch(
        canvas, centerX, centerY - size * 0.1, -size * 0.3, size * 0.15);
    _drawBranch(canvas, centerX, centerY - size * 0.1, size * 0.3, size * 0.15);
    _drawBranch(canvas, centerX, centerY - size * 0.2, 0, size * 0.2);

    // Draw fuller canopy
    _drawCanopy(canvas, centerX, centerY - size * 0.15, size * 0.5, leafPaint);
  }

  // Stage 5: Mature Tree - Large tree with full canopy
  void _drawMatureTree(Canvas canvas, double centerX, double centerY, double canvasSize) {
    _initializePaints();
    _initializeGradients(canvasSize);
    
    final leafPaint = Paint()
      ..shader = _cachedMatureTreeGradient
      ..style = PaintingStyle.fill;

    // Draw thicker trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + size * 0.3),
          width: size * 0.22,
          height: size * 0.6,
        ),
        const Radius.circular(6),
      ),
      _cachedTrunkPaint!,
    );

    // Draw multiple branches
    _drawBranch(canvas, centerX, centerY, -size * 0.35, size * 0.2);
    _drawBranch(canvas, centerX, centerY, size * 0.35, size * 0.2);
    _drawBranch(
        canvas, centerX, centerY - size * 0.1, -size * 0.25, size * 0.18);
    _drawBranch(
        canvas, centerX, centerY - size * 0.1, size * 0.25, size * 0.18);
    _drawBranch(canvas, centerX, centerY - size * 0.2, 0, size * 0.25);

    // Draw large canopy
    _drawCanopy(canvas, centerX, centerY - size * 0.1, size * 0.65, leafPaint);
  }

  // Stage 6+: Majestic Tree - Ancient tree with golden fruit
  void _drawMajesticTree(Canvas canvas, double centerX, double centerY, double canvasSize) {
    _initializePaints();
    _initializeGradients(canvasSize);
    
    final leafPaint = Paint()
      ..shader = _cachedMajesticTreeGradient
      ..style = PaintingStyle.fill;

    // Draw thick, ancient trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + size * 0.35),
          width: size * 0.28,
          height: size * 0.7,
        ),
        const Radius.circular(8),
      ),
      _cachedTrunkPaint!,
    );

    // Draw many branches
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final branchLength = size * (0.3 + (i % 2) * 0.1);
      _drawBranch(
        canvas,
        centerX,
        centerY - size * 0.05 + (i % 3) * size * 0.05,
        math.cos(angle) * branchLength,
        size * 0.25,
      );
    }

    // Draw majestic canopy
    _drawCanopy(canvas, centerX, centerY - size * 0.05, size * 0.8, leafPaint);

    // Draw golden fruit
    canvas.drawCircle(
      Offset(centerX - size * 0.2, centerY - size * 0.3),
      size * 0.08,
      _cachedFruitPaint!,
    );
    canvas.drawCircle(
      Offset(centerX + size * 0.2, centerY - size * 0.25),
      size * 0.08,
      _cachedFruitPaint!,
    );
    canvas.drawCircle(
      Offset(centerX, centerY - size * 0.35),
      size * 0.08,
      _cachedFruitPaint!,
    );
  }

  void _drawLeaf(
      Canvas canvas, double x, double y, double leafSize, Paint paint) {
    final path = Path();
    path.moveTo(x, y);
    path.quadraticBezierTo(
      x + leafSize * 0.3,
      y - leafSize * 0.2,
      x + leafSize * 0.5,
      y - leafSize * 0.1,
    );
    path.quadraticBezierTo(
      x + leafSize * 0.7,
      y - leafSize * 0.2,
      x + leafSize,
      y,
    );
    path.quadraticBezierTo(
      x + leafSize * 0.5,
      y + leafSize * 0.3,
      x,
      y,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLeafCluster(
      Canvas canvas, double x, double y, double clusterSize, Paint paint) {
    _drawLeaf(canvas, x, y, clusterSize, paint);
    _drawLeaf(canvas, x - clusterSize * 0.3, y, clusterSize * 0.7, paint);
    _drawLeaf(canvas, x + clusterSize * 0.3, y, clusterSize * 0.7, paint);
  }

  void _drawBranch(Canvas canvas, double startX, double startY, double offsetX,
      double branchWidth) {
    final branchPaint = Paint()
      ..color = AppColors.treeTrunk
      ..strokeWidth = branchWidth * 0.3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(startX + offsetX, startY - branchWidth * 0.5),
      branchPaint,
    );
  }

  void _drawCanopy(Canvas canvas, double centerX, double centerY,
      double canopySize, Paint paint) {
    canvas.drawCircle(
      Offset(centerX, centerY),
      canopySize * 0.5,
      paint,
    );

    // Add texture with smaller circles
    final texturePaint = Paint()
      ..color = AppColors.treeLeavesLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final radius = canopySize * 0.3;
      canvas.drawCircle(
        Offset(
          centerX + math.cos(angle) * radius,
          centerY + math.sin(angle) * radius,
        ),
        canopySize * 0.15,
        texturePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _PlantPainter) {
      return oldDelegate.evolutionStage != evolutionStage ||
          oldDelegate.size != size;
    }
    return true;
  }
}

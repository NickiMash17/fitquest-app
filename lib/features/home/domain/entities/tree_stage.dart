// lib/features/home/domain/entities/tree_stage.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tree_stage.freezed.dart';

/// Tree stage data class representing different growth stages
@freezed
class TreeStage with _$TreeStage {
  const factory TreeStage({
    required String name,
    required double trunkWidth,
    required double trunkHeightRatio,
    required double canopyRadiusRatio,
  }) = _TreeStage;

  factory TreeStage.seedling() => const TreeStage(
        name: 'Seedling',
        trunkWidth: 8,
        trunkHeightRatio: 0.15,
        canopyRadiusRatio: 0.08,
      );

  factory TreeStage.sprout() => const TreeStage(
        name: 'Sprout',
        trunkWidth: 12,
        trunkHeightRatio: 0.25,
        canopyRadiusRatio: 0.12,
      );

  factory TreeStage.sapling() => const TreeStage(
        name: 'Sapling',
        trunkWidth: 18,
        trunkHeightRatio: 0.35,
        canopyRadiusRatio: 0.18,
      );

  factory TreeStage.youngTree() => const TreeStage(
        name: 'Young Tree',
        trunkWidth: 26,
        trunkHeightRatio: 0.45,
        canopyRadiusRatio: 0.25,
      );

  factory TreeStage.mature() => const TreeStage(
        name: 'Mature Tree',
        trunkWidth: 36,
        trunkHeightRatio: 0.55,
        canopyRadiusRatio: 0.32,
      );

  factory TreeStage.majestic() => const TreeStage(
        name: 'Majestic Tree',
        trunkWidth: 48,
        trunkHeightRatio: 0.65,
        canopyRadiusRatio: 0.40,
      );
}

import 'dart:ui';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_hit_region.dart';

class MuscleMapData {
  MuscleMapData._();

  static const Map<MuscleBodySide, String> assets = {
    MuscleBodySide.front: AppImages.muscleFront,
    MuscleBodySide.back: AppImages.muscleBack,
  };

  static const Map<MuscleBodySide, Size> viewBoxes = {
    MuscleBodySide.front: Size(83, 161),
    MuscleBodySide.back: Size(85, 161),
  };

  static const Map<MuscleBodySide, Map<MuscleGroup, List<int>>> shapes = {
    MuscleBodySide.front: {
      MuscleGroup.chest: [93, 94],
      MuscleGroup.shoulders: [91, 92, 122, 124],
      MuscleGroup.biceps: [
        46,
        47,
        48,
        49,
        50,
        51,
        52,
        53,
        54,
        55,
        56,
        57,
        58,
        59,
        60,
        61,
        62,
        63,
        64,
        65,
      ],
      MuscleGroup.abdominals: [85, 86, 87, 88, 89, 90],
      MuscleGroup.quadriceps: [20, 21, 26, 28, 34, 35, 36, 37],
      MuscleGroup.adductors: [22, 23, 24, 25, 30, 31, 32, 33, 38, 39],
      MuscleGroup.calves: [
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        15,
        16,
        17,
        18,
        19,
        128,
        129,
        130,
        131,
        132,
        133,
        134,
        135,
        138,
        139,
        140,
        141,
        142,
      ],
    },
    MuscleBodySide.back: {
      MuscleGroup.traps: [65, 66, 71, 73],
      MuscleGroup.back: [25, 26, 27, 28, 55, 56, 67, 69],
      MuscleGroup.shoulders: [53, 54, 57, 58, 59, 60, 61, 63],
      MuscleGroup.triceps: [
        35,
        36,
        37,
        38,
        39,
        40,
        41,
        42,
        43,
        44,
        45,
        46,
        47,
        48,
        49,
        50,
      ],
      MuscleGroup.glutes: [21, 22, 23, 24],
      MuscleGroup.hamstrings: [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
      MuscleGroup.calves: [5, 6, 19, 20, 84, 85, 86, 87],
    },
  };

  static const Map<MuscleBodySide, List<MuscleHitRegion>> hitRegions = {
    MuscleBodySide.front: [
      MuscleHitRegion(
        group: MuscleGroup.biceps,
        bounds: Rect.fromLTRB(7, 34, 27, 74),
      ),
      MuscleHitRegion(
        group: MuscleGroup.biceps,
        bounds: Rect.fromLTRB(56, 34, 76, 74),
      ),
      MuscleHitRegion(
        group: MuscleGroup.shoulders,
        bounds: Rect.fromLTRB(18, 26, 29, 43),
      ),
      MuscleHitRegion(
        group: MuscleGroup.shoulders,
        bounds: Rect.fromLTRB(54, 26, 65, 43),
      ),
      MuscleHitRegion(
        group: MuscleGroup.chest,
        bounds: Rect.fromLTRB(29, 26, 54, 42.5),
      ),
      MuscleHitRegion(
        group: MuscleGroup.abdominals,
        bounds: Rect.fromLTRB(32, 42.5, 51, 62),
      ),
      MuscleHitRegion(
        group: MuscleGroup.adductors,
        bounds: Rect.fromLTRB(35.5, 64, 47.5, 110),
      ),
      MuscleHitRegion(
        group: MuscleGroup.quadriceps,
        bounds: Rect.fromLTRB(24, 64, 35.5, 110),
      ),
      MuscleHitRegion(
        group: MuscleGroup.quadriceps,
        bounds: Rect.fromLTRB(47.5, 64, 59, 110),
      ),
      MuscleHitRegion(
        group: MuscleGroup.calves,
        bounds: Rect.fromLTRB(25, 110, 58, 150),
      ),
    ],
    MuscleBodySide.back: [
      MuscleHitRegion(
        group: MuscleGroup.triceps,
        bounds: Rect.fromLTRB(7, 35, 26, 74),
      ),
      MuscleHitRegion(
        group: MuscleGroup.triceps,
        bounds: Rect.fromLTRB(57, 35, 76, 74),
      ),
      MuscleHitRegion(
        group: MuscleGroup.shoulders,
        bounds: Rect.fromLTRB(18.5, 27, 29, 43),
      ),
      MuscleHitRegion(
        group: MuscleGroup.shoulders,
        bounds: Rect.fromLTRB(54, 27, 65, 43),
      ),
      MuscleHitRegion(
        group: MuscleGroup.traps,
        bounds: Rect.fromLTRB(23, 12, 60, 30),
      ),
      MuscleHitRegion(
        group: MuscleGroup.back,
        bounds: Rect.fromLTRB(25.5, 30, 57.5, 62),
      ),
      MuscleHitRegion(
        group: MuscleGroup.glutes,
        bounds: Rect.fromLTRB(26.5, 62, 56.5, 84),
      ),
      MuscleHitRegion(
        group: MuscleGroup.hamstrings,
        bounds: Rect.fromLTRB(25.5, 84, 57.5, 112),
      ),
      MuscleHitRegion(
        group: MuscleGroup.calves,
        bounds: Rect.fromLTRB(26, 112, 58, 150),
      ),
    ],
  };
}

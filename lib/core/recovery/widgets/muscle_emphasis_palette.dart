import 'dart:ui';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/recovery/models/muscle_emphasis.dart';
import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/services/muscle_targeting.dart';

extension MuscleEmphasisPalette on MuscleEmphasis {
  Color mapColor(AppColorTokens colors) => switch (this) {
    MuscleEmphasis.primary => colors.primary,
    MuscleEmphasis.secondary => Color.alphaBlend(
      colors.primary.withValues(alpha: AppOpacity.muscleSecondary),
      MuscleMapService.baseColor,
    ),
  };
}

extension MuscleTargetsPalette on MuscleTargets {
  Map<MuscleGroup, Color> paletteOf(AppColorTokens colors) => {
    for (final entry in emphasis.entries)
      entry.key: entry.value.mapColor(colors),
  };
}

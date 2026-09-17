import 'dart:ui';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';

extension MuscleStatusPalette on MuscleRecoveryStatus {
  Color mapColor(AppColorTokens colors) => switch (this) {
    MuscleRecoveryStatus.ready => colors.primaryAlt,
    MuscleRecoveryStatus.recovering => colors.accentOrange,
    MuscleRecoveryStatus.fatigued => colors.destructiveBorder,
  };

  Color highlightColor(AppColorTokens colors) => switch (this) {
    MuscleRecoveryStatus.ready => colors.primary,
    MuscleRecoveryStatus.recovering => colors.accentOrange,
    MuscleRecoveryStatus.fatigued => colors.destructiveBorder,
  };

  Color valueColor(AppColorTokens colors) => switch (this) {
    MuscleRecoveryStatus.ready => colors.textPrimary,
    MuscleRecoveryStatus.recovering => colors.accentOrange,
    MuscleRecoveryStatus.fatigued => colors.destructiveBorder,
  };
}

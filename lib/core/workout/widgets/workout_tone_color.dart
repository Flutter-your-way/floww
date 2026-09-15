import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

extension WorkoutStatToneColor on WorkoutStatTone {
  Color resolve(BuildContext context) {
    final colors = context.colors;
    return switch (this) {
      WorkoutStatTone.neutral => colors.textPrimary,
      WorkoutStatTone.accent => colors.primaryAlt,
      WorkoutStatTone.alert => colors.destructive,
      WorkoutStatTone.ember => colors.accentOrangeDeep,
      WorkoutStatTone.warning => colors.accentOrange,
    };
  }
}

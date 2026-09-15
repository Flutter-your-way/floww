import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class CompletionStatBox extends StatelessWidget {
  const CompletionStatBox({super.key, required this.stat});

  final WorkoutStatItem stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: WorkoutStatTile(
        stat: stat,
        titleStyle: AppTypography.bodyMediumMedium.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

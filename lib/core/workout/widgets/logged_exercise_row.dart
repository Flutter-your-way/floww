import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/log_workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class LoggedExerciseRow extends StatelessWidget {
  const LoggedExerciseRow({
    super.key,
    required this.exercise,
    required this.onRemove,
  });

  final LoggedExerciseItem exercise;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exercise.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMediumMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          WorkoutChip(label: exercise.summaryLabel),
          SizedBox(width: AppSpacing.sm),
          PressScale(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: AppSizes.s20,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

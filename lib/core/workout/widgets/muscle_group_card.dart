import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';

class MuscleGroupCard extends StatelessWidget {
  const MuscleGroupCard({
    super.key,
    required this.group,
    this.onToggle,
    this.onToggleExercise,
  });

  final ExerciseGroupItem group;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onToggleExercise;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const WorkoutIconTile(),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall,
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        group.countLabel,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Icon(
                  group.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: AppSizes.s24,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          if (group.isExpanded)
            for (final exercise in group.exercises) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Container(
                  height: AppSizes.s1,
                  color: colors.borderSubtle,
                ),
              ),
              _ExerciseRow(
                exercise: exercise,
                onToggle: onToggleExercise == null
                    ? null
                    : () => onToggleExercise!(exercise.id),
              ),
            ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, this.onToggle});

  final ExerciseRowItem exercise;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: AppSizes.s36,
          height: AppSizes.s36,
          alignment: Alignment.center,
          decoration: AppShapes.decoration(
            color: colors.borderSubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.subdirectory_arrow_right,
            size: AppSizes.s16,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            exercise.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyLarge,
          ),
        ),
        if (exercise.isCustom) ...[
          SizedBox(width: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: AppShapes.decoration(
              color: colors.bgTinted,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              'CUSTOM',
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.primaryAlt,
              ),
            ),
          ),
        ],
        SizedBox(width: AppSpacing.md),
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: AppSizes.s40,
            height: AppSizes.s40,
            alignment: Alignment.center,
            decoration: AppShapes.decoration(
              color: exercise.isAdded
                  ? colors.backgroundElevated
                  : colors.backgroundSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
            ),
            child: Icon(
              exercise.isAdded ? Icons.check : Icons.add,
              size: AppSizes.s20,
              color: exercise.isAdded ? colors.textPrimary : colors.primaryAlt,
            ),
          ),
        ),
      ],
    );
  }
}

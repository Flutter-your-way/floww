import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_collapsible_section.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/widgets/workout_icon_tile.dart';

class MuscleGroupCard extends StatelessWidget {
  const MuscleGroupCard({
    super.key,
    required this.group,
    this.onToggle,
    this.onOpenExercise,
    this.onToggleSaved,
  });

  final ExerciseGroupItem group;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<String>? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PressScale(
            onTap: onToggle,
            child: Row(
              children: [
                WorkoutIconTile(
                  imageUrl: group.imageUrl,
                  backgroundColor: colors.textPrimary.withValues(
                    alpha: AppOpacity.frostedTile,
                  ),
                ),
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
                        style: AppTypography.heading4SemiBold.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        group.countLabel,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                AnimatedRotation(
                  turns: group.isExpanded ? AppMotion.halfTurn : 0,
                  duration: AppMotion.expandSoft,
                  curve: AppMotion.expandCurve,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: AppSizes.s24,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppCollapsibleSection(
            visible: group.isExpanded,
            duration: AppMotion.expandSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    onOpen: onOpenExercise == null
                        ? null
                        : () => onOpenExercise!(exercise.id),
                    onToggleSaved: onToggleSaved == null
                        ? null
                        : () => onToggleSaved!(exercise.id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, this.onOpen, this.onToggleSaved});

  final ExerciseRowItem exercise;
  final VoidCallback? onOpen;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSaved = exercise.isSaved;

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AppPhotoTile(
            url: exercise.imageUrl,
            fallbackIcon: Icons.fitness_center,
            size: AppSizes.s40,
            radius: AppRadius.sm,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
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
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
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
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  exercise.detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onToggleSaved,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: AppSizes.s40,
              height: AppSizes.s40,
              alignment: Alignment.center,
              decoration: AppShapes.decoration(
                color: isSaved
                    ? colors.bgTinted
                    : colors.textPrimary.withValues(
                        alpha: AppOpacity.frostedTile,
                      ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(
                  color: isSaved ? colors.primary : colors.borderSubtle,
                  width: AppSizes.s1,
                ),
              ),
              child: Icon(
                isSaved ? Icons.star_rounded : Icons.star_outline_rounded,
                size: AppSizes.s20,
                color: isSaved ? colors.primaryAlt : colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/bright_action_button.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_hero_photo.dart';

class TodayWorkoutHeroCard extends StatelessWidget {
  const TodayWorkoutHeroCard({super.key, required this.workout, this.onTap});

  final WorkoutSuggestionItem workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(AppRadius.xl);

    return PressScale(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppShapes.decoration(
          color: colors.backgroundPrimary,
          borderRadius: borderRadius,
        ),
        foregroundDecoration: AppShapes.decoration(
          borderRadius: borderRadius,
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              fit: StackFit.passthrough,
              children: [
                WorkoutHeroPhoto(imageUrl: workout.imageUrl),
                Positioned(
                  top: AppSpacing.lg,
                  left: AppSpacing.lg,
                  child: AppStatusChip(label: workout.eyebrow),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl2,
                AppSpacing.xs,
                AppSpacing.xl2,
                AppSpacing.xl,
              ),
              child: _HeroDetails(workout: workout, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDetails extends StatelessWidget {
  const _HeroDetails({required this.workout, this.onTap});

  final WorkoutSuggestionItem workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contextLabel = workout.contextLabel;
    final actionLabel = workout.actionLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title.toUpperCase(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.photoCardTitle.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          children: [
            for (final label in workout.metaLabels)
              Text(
                label,
                style: AppTypography.bodyMediumRegular.copyWith(
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
        if (contextLabel != null) ...[
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: AppSizes.s16,
                color: colors.textMuted,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  contextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (actionLabel != null) ...[
          SizedBox(height: AppSpacing.xl),
          BrightActionButton(
            label: actionLabel,
            icon: Icons.visibility_outlined,
            onPressed: onTap,
          ),
        ],
      ],
    );
  }
}

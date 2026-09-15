import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class WorkoutExerciseRow extends StatelessWidget {
  const WorkoutExerciseRow({super.key, required this.exercise, this.imageUrl});

  static const double _thumbnailSize = AppSizes.s56;

  final WorkoutExerciseItem exercise;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _thumbnailSize,
            height: _thumbnailSize,
            clipBehavior: Clip.antiAlias,
            decoration: AppShapes.decoration(
              color: colors.backgroundElevated,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: RemoteImage(
              url: imageUrl,
              fallbackIcon: Icons.fitness_center,
              fallbackIconSize: AppSizes.s24,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLargeMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  exercise.setsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Flexible(
                      child: _ExerciseMetric(
                        icon: Icons.fitness_center,
                        value: exercise.weightLabel,
                        label: 'Weight',
                      ),
                    ),
                    SizedBox(width: AppSpacing.xl),
                    Flexible(
                      child: _ExerciseMetric(
                        icon: Icons.schedule,
                        value: '${exercise.restLabel} min',
                        label: 'Rest',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.volumeLabel,
                style: AppTypography.bodyLargeMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                'kg vol.',
                style: AppTypography.captionMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseMetric extends StatelessWidget {
  const _ExerciseMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.s14, color: colors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: colors.textPrimary,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $label',
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

import 'package:floww/config/widgets/animations/app_card_pop.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/widgets/active_metric_pill.dart';

class ActiveExerciseHeroCard extends StatelessWidget {
  const ActiveExerciseHeroCard({
    super.key,
    required this.exercise,
    required this.onOptions,
  });

  static const double _aspectRatio = 3 / 4;

  final ActiveExerciseItem exercise;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final supersetLabel = exercise.supersetLabel;

    return AppCardPop(
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: AppShapes.decoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RemoteImage(
                url: exercise.imageUrl,
                fallbackIcon: Icons.fitness_center,
                fallbackIconSize: AppSizes.s64,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: context.gradients.cameraScrim,
                ),
              ),
              Positioned(
                top: AppSpacing.xl,
                right: AppSpacing.xl,
                child: CircularHeaderButton(
                  icon: Icons.more_horiz_rounded,
                  iconColor: colors.textPrimary,
                  backgroundColor: colors.surfaceTranslucent,
                  borderColor: colors.borderMedium,
                  onPressed: onOptions,
                ),
              ),
              if (supersetLabel != null)
                Positioned(
                  top: AppSpacing.xl,
                  left: AppSpacing.xl,
                  right: AppSizes.s72,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ActiveMetricPill(
                      icon: Icons.link_rounded,
                      value: 'Superset',
                      label: supersetLabel,
                    ),
                  ),
                ),
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading2Bold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Flexible(
                          child: ActiveMetricPill(
                            value: exercise.setsValue,
                            label: exercise.setsLabel,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Text(
                          '•',
                          style: AppTypography.bodyMediumMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: ActiveMetricPill(
                            value: exercise.repsValue,
                            label: exercise.repsLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

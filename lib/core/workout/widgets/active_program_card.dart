import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class ActiveProgramCard extends StatelessWidget {
  const ActiveProgramCard({super.key, required this.program});

  final ActiveProgramItem program;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;
    final radius = BorderRadius.circular(AppRadius.xl);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: AppShapes.decoration(
              gradient: gradients.darkGlow,
              borderRadius: radius,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: AppShapes.decoration(
              gradient: gradients.cardSheen,
              borderRadius: radius,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.s48,
                    height: AppSizes.s48,
                    alignment: Alignment.center,
                    decoration: AppShapes.decoration(
                      color: colors.bgTinted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: AppSizes.s24,
                      color: colors.primaryAlt,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          program.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.heading4SemiBold.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          program.scheduleLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmallRegularTight.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  WorkoutChip(
                    label: program.statusLabel,
                    tone: WorkoutChipTone.filled,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              AppProgressBar(
                progress: program.progress,
                color: colors.primaryAlt,
                trackColor: colors.borderSubtle,
                height: AppSizes.s8,
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.levelLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Text(
                    program.progressLabel,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

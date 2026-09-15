import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({super.key, required this.summary, this.onInfo});

  static const double _statRowHeight = AppSizes.s56;

  final WorkoutSummaryItem summary;
  final VoidCallback? onInfo;

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
              CardHeader(
                title: 'Workout Summary',
                onTap: onInfo,
                icon: Icons.bolt,
                iconColor: colors.textPrimary,
                titleStyle: AppTypography.heading4SemiBold.copyWith(
                  color: colors.textPrimary,
                ),
                titleTrailing: Icon(
                  Icons.info_outline,
                  size: AppSizes.s16,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              _WorkoutIdentityRow(summary: summary),
              SizedBox(height: AppSpacing.xl),
              _StatRow(
                stats: summary.stats.take(2).toList(),
                alignment: CrossAxisAlignment.start,
              ),
              Container(height: AppSizes.s1, color: colors.borderMedium),
              _StatRow(
                stats: summary.stats.skip(2).toList(),
                alignment: CrossAxisAlignment.end,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkoutIdentityRow extends StatelessWidget {
  const _WorkoutIdentityRow({required this.summary});

  final WorkoutSummaryItem summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
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
                summary.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading4SemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: AppSizes.s8,
                    height: AppSizes.s8,
                    decoration: AppShapes.decoration(
                      color: colors.fiberAccent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      shadows: [
                        BoxShadow(
                          color: colors.fiberAccent,
                          blurRadius: AppSizes.s8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      summary.exercisesLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.primaryAlt,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.bolt,
                    size: AppSizes.s12,
                    color: colors.primaryAlt,
                  ),
                  Flexible(
                    child: Text(
                      summary.flowPointsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSemiBold.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        WorkoutChip(
          label: summary.statusLabel,
          icon: summary.isCompleted ? Icons.check : null,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stats, required this.alignment});

  final List<WorkoutStatItem> stats;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: WorkoutSummaryCard._statRowHeight,
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) ...[
              SizedBox(width: AppSpacing.xl),
              Container(
                width: AppSizes.s1,
                height: WorkoutSummaryCard._statRowHeight,
                color: context.colors.borderMedium,
              ),
              SizedBox(width: AppSpacing.xl),
            ],
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: WorkoutStatTile(stat: stats[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

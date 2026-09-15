import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class WorkoutDetailSummaryCard extends StatelessWidget {
  const WorkoutDetailSummaryCard({super.key, required this.detail});

  static const double _statRowHeight = AppSizes.s52;

  final WorkoutDetailItem detail;

  @override
  Widget build(BuildContext context) {
    final stats = detail.stats;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityRow(detail: detail),
          SizedBox(height: AppSpacing.xl2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatColumn(
                    stats: [stats[0], if (stats.length > 2) stats[2]],
                  ),
                ),
                SizedBox(width: AppSpacing.xl),
                Container(
                  width: AppSizes.s1,
                  color: context.colors.borderMedium,
                ),
                SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: _StatColumn(
                    stats: [
                      if (stats.length > 1) stats[1],
                      if (stats.length > 3) stats[3],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.detail});

  final WorkoutDetailItem detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: AppSizes.s56,
          height: AppSizes.s56,
          alignment: Alignment.center,
          decoration: AppShapes.decoration(
            color: colors.bgTinted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.fitness_center,
            size: AppSizes.s28,
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
                detail.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading4SemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                detail.dateLabel,
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
          label: detail.statusLabel,
          icon: detail.isCompleted ? Icons.check : null,
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stats});

  final List<WorkoutStatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0)
            Container(height: AppSizes.s1, color: context.colors.borderMedium),
          SizedBox(
            height: WorkoutDetailSummaryCard._statRowHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: WorkoutStatTile(stat: stats[i]),
            ),
          ),
        ],
      ],
    );
  }
}

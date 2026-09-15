import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class TodaysWorkoutSummaryCard extends StatelessWidget {
  const TodaysWorkoutSummaryCard({super.key, required this.workout});

  final TodayWorkoutItem workout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityRow(workout: workout),
          SizedBox(height: AppSpacing.xl),
          _StatsBox(workout: workout),
          SizedBox(height: AppSpacing.lg),
          TipCard.inline(
            title: workout.goalTitle,
            message: workout.goal,
            icon: Icons.track_changes,
          ),
        ],
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.workout});

  final TodayWorkoutItem workout;

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
            workout.icon,
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
                workout.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading4SemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                workout.programLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsBox extends StatelessWidget {
  const _StatsBox({required this.workout});

  final TodayWorkoutItem workout;

  @override
  Widget build(BuildContext context) {
    final stats = workout.stats;

    return AppCard(
      variant: AppCardVariant.innerGlow,
      radius: AppRadius.lg,
      glowOpacity: AppOpacity.innerGlow,
      glowBlur: AppSizes.s8,
      borderColor: context.colors.borderGlow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) ...[
                SizedBox(width: AppSpacing.lg),
                Container(
                  width: AppSizes.s1,
                  color: context.colors.borderMedium,
                ),
                SizedBox(width: AppSpacing.lg),
              ],
              Expanded(child: WorkoutStatTile(stat: stats[i])),
            ],
          ],
        ),
      ),
    );
  }
}

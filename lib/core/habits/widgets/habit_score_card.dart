import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';

class HabitScoreCard extends StatelessWidget {
  const HabitScoreCard({
    super.key,
    required this.scoreLabel,
    required this.scoreTotalLabel,
    required this.headline,
    required this.message,
    required this.dailyScoreLabel,
    required this.flowPointsLabel,
    required this.progress,
    required this.stats,
  });

  final String scoreLabel;
  final String scoreTotalLabel;
  final String headline;
  final String message;
  final String dailyScoreLabel;
  final String flowPointsLabel;
  final double progress;
  final List<HabitStatItem> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: context.gradients.darkGlow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: context.gradients.cardSheen),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(title: 'Habit Score', icon: Icons.bolt),
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreSummary(
                        scoreLabel: scoreLabel,
                        scoreTotalLabel: scoreTotalLabel,
                        headline: headline,
                        message: message,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xl2),
                    _ScoreRing(
                      progress: progress,
                      dailyScoreLabel: dailyScoreLabel,
                      flowPointsLabel: flowPointsLabel,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Divider(
                  height: AppSizes.s1,
                  thickness: AppSizes.s1,
                  color: colors.borderMedium,
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stat in stats)
                      Expanded(child: _StatColumn(stat: stat)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({
    required this.scoreLabel,
    required this.scoreTotalLabel,
    required this.headline,
    required this.message,
  });

  final String scoreLabel;
  final String scoreTotalLabel;
  final String headline;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(scoreLabel, style: AppTypography.bodyXXXLargeBold),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                scoreTotalLabel,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Container(
              width: AppSizes.s8,
              height: AppSizes.s8,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: colors.success, blurRadius: AppSizes.s8),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                headline,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMediumMediumTight.copyWith(
                  color: colors.primaryAlt,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          message,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.progress,
    required this.dailyScoreLabel,
    required this.flowPointsLabel,
  });

  final double progress;
  final String dailyScoreLabel;
  final String flowPointsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = AppTypography.captionMedium.copyWith(
      color: colors.textSecondary,
    );

    return AppProgressRing(
      progress: progress,
      size: AppSizes.s100,
      strokeWidth: AppSizes.s10,
      gradient: context.gradients.full,
      trackColor: colors.textTertiary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Daily Score', style: captionStyle),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dailyScoreLabel,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text('%', style: captionStyle),
              ),
            ],
          ),
          Text(
            flowPointsLabel,
            style: AppTypography.captionSemiBold.copyWith(
              color: colors.primaryAlt,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});

  final HabitStatItem stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.title,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionSemiBold.copyWith(
            color: colors.textSubtle,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(stat.value, style: AppTypography.bodyXLargeBold),
            SizedBox(width: AppSpacing.xxs),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                stat.unit,
                style: AppTypography.bodyXSmallRegular.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

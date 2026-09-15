import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/flow_points_row.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/core/nutrition/widgets/weekly_bar_chart.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FlowContributionCard extends StatelessWidget {
  const FlowContributionCard({
    super.key,
    required this.pointsLabel,
    required this.maxLabel,
    required this.progress,
    required this.progressLabel,
    required this.dailyBars,
  });

  final String pointsLabel;
  final String maxLabel;
  final double progress;
  final String progressLabel;
  final List<ChartBar> dailyBars;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return AppCard(
      variant: AppCardVariant.accentOutline,
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⚡', style: context.textTheme.titleLarge),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLOW Contribution',
                      style: context.textTheme.titleLarge,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text('This week\'s nutrition impact', style: captionStyle),
                  ],
                ),
              ),
              Container(
                width: AppSizes.s1,
                height: AppSizes.s36,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: colors.borderMedium,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pointsLabel,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('Flow Points', style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppProgressBar(progress: progress, height: AppSizes.s8),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('0', style: captionStyle),
              Expanded(
                child: Text(
                  progressLabel,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
              Text(maxLabel, style: captionStyle),
            ],
          ),
          SizedBox(height: AppSpacing.xl2),
          Divider(
            height: AppSizes.s1,
            thickness: AppSizes.s1,
            color: colors.borderSubtle,
          ),
          SizedBox(height: AppSpacing.xl2),
          Text('Daily Breakdown', style: context.textTheme.titleLarge),
          SizedBox(height: AppSpacing.xl),
          WeeklyBarChart(
            bars: dailyBars,
            color: colors.primary,
            barAreaHeight: AppSizes.s64,
          ),
        ],
      ),
    );
  }
}

class ConsistencyCard extends StatelessWidget {
  const ConsistencyCard({
    super.key,
    required this.daysLogged,
    required this.calorieStreak,
    required this.proteinStreak,
    required this.statuses,
  });

  final String daysLogged;
  final String calorieStreak;
  final String proteinStreak;
  final List<DayStatusItem> statuses;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'Consistency'),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: daysLogged,
                  label: 'Days Logged',
                  caption: 'This week',
                  color: colors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatTile(
                  value: calorieStreak,
                  label: 'Calorie Streak',
                  caption: '≥70% calorie goal',
                  color: colors.accentOrange,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatTile(
                  value: proteinStreak,
                  label: 'Protein Streak',
                  caption: '≥70% protein goal',
                  color: colors.accentViolet,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Divider(
            height: AppSizes.s1,
            thickness: AppSizes.s1,
            color: colors.borderSubtle,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (final item in statuses)
                Expanded(
                  child: Column(
                    children: [
                      _StatusDot(status: item.status),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        item.label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xs,
              children: [
                for (final status in DayLogStatus.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusDot(status: status, size: AppSizes.s10),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        status.label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.caption,
    required this.color,
  });

  final String value;
  final String label;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.textTheme.displaySmall?.copyWith(color: color),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(label, style: context.textTheme.labelMedium),
          SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, this.size = AppSizes.s16});

  final DayLogStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: status.colorOf(context),
        shape: BoxShape.circle,
      ),
    );
  }
}

class WeeklyMetricCard extends StatelessWidget {
  const WeeklyMetricCard({
    super.key,
    required this.title,
    required this.averageLabel,
    required this.goalLabel,
    required this.bars,
    required this.color,
    required this.totalLabel,
    required this.weeklyGoalLabel,
    required this.progress,
  });

  final String title;
  final String averageLabel;
  final String goalLabel;
  final List<ChartBar> bars;
  final Color color;
  final String totalLabel;
  final String weeklyGoalLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: color.withValues(alpha: AppOpacity.tintBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: context.textTheme.titleLarge)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageLabel,
                    style: AppTypography.bodyLargeBold.copyWith(color: color),
                  ),
                  Text(goalLabel, style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          WeeklyBarChart(
            bars: bars,
            color: color,
            barAreaHeight: AppSizes.s160,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(totalLabel, style: AppTypography.bodyLargeBold),
                    Text('weekly total', style: captionStyle),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weeklyGoalLabel,
                    style: AppTypography.bodyLargeBold.copyWith(color: color),
                  ),
                  Text('weekly goal', style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppProgressBar(
            progress: progress,
            color: color,
            height: AppSizes.s8,
          ),
        ],
      ),
    );
  }
}

class FlowPointsBreakdownCard extends StatelessWidget {
  const FlowPointsBreakdownCard({
    super.key,
    required this.totalLabel,
    required this.maxLabel,
    required this.rows,
    required this.tip,
  });

  final String totalLabel;
  final String maxLabel;
  final List<FlowPointRow> rows;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('⚡', style: context.textTheme.titleLarge),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Nutrition FLOW Points',
                  style: context.textTheme.titleLarge,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: totalLabel,
                      style: AppTypography.bodyLargeBold.copyWith(
                        color: colors.primary,
                      ),
                      children: [
                        TextSpan(
                          text: ' /$maxLabel',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'this week',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          FlowPointsRowList(rows: rows, showDividers: true),
          SizedBox(height: AppSpacing.xl),
          TipCard.inline(title: 'Tip', message: tip),
        ],
      ),
    );
  }
}

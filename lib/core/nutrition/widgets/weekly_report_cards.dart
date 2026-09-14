import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/flow_points_row.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/core/nutrition/widgets/nutrition_tip_card.dart';
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
      variant: AppCardVariant.glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: colors.primary, size: AppSizes.s20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLOW Contribution',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('This week\'s nutrition impact', style: captionStyle),
                  ],
                ),
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
          SizedBox(height: AppSpacing.xl),
          Text(
            'Daily Breakdown',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
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
                  color: colors.proteinAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in statuses)
                Column(
                  children: [
                    _StatusDot(status: item.status),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      item.label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              for (final status in DayLogStatus.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusDot(status: status, size: AppSizes.s8),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      status.label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(color: color),
          ),
          Text(label, style: context.textTheme.labelMedium),
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    averageLabel,
                    style: context.textTheme.labelLarge?.copyWith(color: color),
                  ),
                  Text(goalLabel, style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          WeeklyBarChart(bars: bars, color: color),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('weekly total', style: captionStyle),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weeklyGoalLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('weekly goal', style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppProgressBar(progress: progress, color: color),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: colors.primary, size: AppSizes.s20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Nutrition FLOW Points',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: totalLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: ' / $maxLabel',
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
          SizedBox(height: AppSpacing.sm),
          FlowPointsRowList(rows: rows),
          SizedBox(height: AppSpacing.md),
          NutritionTipCard(title: 'Tip', message: tip),
        ],
      ),
    );
  }
}

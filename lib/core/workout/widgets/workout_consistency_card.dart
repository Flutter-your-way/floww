import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_day_marker.dart';
import 'package:floww/core/workout/widgets/workout_tone_color.dart';

class WorkoutConsistencyCard extends StatelessWidget {
  const WorkoutConsistencyCard({super.key, required this.consistency});

  final WorkoutConsistencyItem consistency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = consistency.progress;
    final insight = consistency.insight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(label: consistency.periodLabel),
              SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    consistency.headline,
                    style: AppTypography.bodyXXLargeBold.copyWith(
                      color: colors.primaryAlt,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        consistency.caption,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (progress != null) ...[
                SizedBox(height: AppSpacing.md),
                AppProgressBar(
                  progress: progress,
                  color: colors.primaryAlt,
                  trackColor: colors.backgroundSurface,
                  animated: true,
                  animationDelay: AppMotion.tabSwitch,
                ),
              ],
              SizedBox(height: AppSpacing.xl2),
              Row(
                children: [
                  for (final stat in consistency.stats)
                    Expanded(child: _ConsistencyStat(stat: stat)),
                ],
              ),
              SizedBox(height: AppSpacing.xl2),
              _ConsistencyGrid(
                weekdayLabels: consistency.weekdayLabels,
                days: consistency.days,
              ),
              SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.md,
                children: [
                  for (final mark in consistency.legend)
                    _LegendEntry(mark: mark),
                ],
              ),
            ],
          ),
        ),
        if (insight != null) ...[
          SizedBox(height: AppSpacing.lg),
          TipCard.note(title: insight),
        ],
      ],
    );
  }
}

class _ConsistencyStat extends StatelessWidget {
  const _ConsistencyStat({required this.stat});

  final WorkoutConsistencyStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.value,
          style: AppTypography.bodyXLargeBold.copyWith(
            color: stat.tone.resolve(context),
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          stat.label,
          style: AppTypography.labelSmallMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ConsistencyGrid extends StatelessWidget {
  const _ConsistencyGrid({required this.weekdayLabels, required this.days});

  final List<String> weekdayLabels;
  final List<WorkoutDayMarkItem> days;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmallRegular.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        for (var row = 0; row < days.length; row += DateTime.daysPerWeek) ...[
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var column = 0; column < DateTime.daysPerWeek; column++)
                Expanded(
                  child: row + column < days.length
                      ? Center(
                          child: WorkoutDayMarker(
                            mark: days[row + column].mark,
                            label: days[row + column].label,
                            isToday: days[row + column].isToday,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.mark});

  final WorkoutDayMark mark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorkoutDayMarker(mark: mark, size: AppSizes.s12),
        SizedBox(width: AppSpacing.sm),
        Text(
          mark.label,
          style: AppTypography.labelSmallMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

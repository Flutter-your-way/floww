import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';
import 'package:floww/core/habits/models/habit_day.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_status_icon.dart';

class HabitHeatmapTooltip extends StatelessWidget {
  const HabitHeatmapTooltip({super.key, required this.cell});

  static const List<HabitDayStatus> _countedStatuses = [
    HabitDayStatus.completed,
    HabitDayStatus.partial,
    HabitDayStatus.missed,
  ];

  final HabitHeatmapCell cell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final counts = [
      for (final status in _countedStatuses)
        if (cell.countOf(status) > 0) status,
    ];

    return Container(
      width: AppSizes.s280,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppShapes.decoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
        shadows: [
          BoxShadow(color: colors.scrim, blurRadius: AppSizes.s32),
          BoxShadow(
            color: colors.primary.withValues(alpha: AppOpacity.softGlow),
            blurRadius: AppSizes.s24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TooltipHeader(cell: cell),
          if (counts.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final status in counts)
                  _StatusCountPill(status: status, count: cell.countOf(status)),
              ],
            ),
          ],
          if (cell.entries.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            Container(height: AppSizes.s1, color: colors.borderSubtle),
            for (final entry in cell.entries) ...[
              SizedBox(height: AppSpacing.lg),
              _TooltipEntry(entry: entry),
            ],
          ],
        ],
      ),
    );
  }
}

class _TooltipHeader extends StatelessWidget {
  const _TooltipHeader({required this.cell});

  final HabitHeatmapCell cell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cell.weekdayLabel,
                style: AppTypography.captionSemiBold.copyWith(
                  color: cell.isToday ? colors.primary : colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                cell.dateLabel,
                style: AppTypography.bodyLargeBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                cell.summaryLabel,
                style: AppTypography.captionMediumSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        AppProgressRing(
          progress: cell.completion,
          size: AppSizes.s48,
          strokeWidth: AppSizes.s4,
          trackColor: colors.borderSubtle,
          glowColor: colors.primary,
          child: Text(
            cell.percentLabel,
            style: AppTypography.captionSemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCountPill extends StatelessWidget {
  const _StatusCountPill({required this.status, required this.count});

  static const double _partialProgress = 0.7;

  final HabitDayStatus status;
  final int count;

  String get _label => switch (status) {
    HabitDayStatus.completed => 'Done',
    HabitDayStatus.partial => 'Partial',
    HabitDayStatus.missed => 'Missed',
    HabitDayStatus.rest => 'Rest',
    HabitDayStatus.upcoming => 'Upcoming',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HabitStatusIcon(
            status: status,
            progress: _partialProgress,
            size: AppSizes.s10,
            strokeWidth: AppSizes.s1,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            '$count $_label',
            style: AppTypography.captionMediumSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TooltipEntry extends StatelessWidget {
  const _TooltipEntry({required this.entry});

  final HabitHeatmapEntry entry;

  Color _percentColor(AppColorTokens colors) => switch (entry.status) {
    HabitDayStatus.completed => colors.primary,
    HabitDayStatus.partial => colors.textPrimary,
    HabitDayStatus.missed => colors.destructive,
    HabitDayStatus.rest || HabitDayStatus.upcoming => colors.textQuiet,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        HabitStatusIcon(
          status: entry.status,
          progress: entry.progress,
          size: AppSizes.s16,
          strokeWidth: AppSizes.s2,
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmallSemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                entry.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionMediumSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          entry.percentLabel,
          style: AppTypography.bodySmallBoldTight.copyWith(
            color: _percentColor(colors),
          ),
        ),
      ],
    );
  }
}

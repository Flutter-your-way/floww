import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/achievements/models/streak_day.dart';
import 'package:floww/core/achievements/models/streak_day_status.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/widgets/streak_day_marker.dart';

class StreakWeekCard extends StatelessWidget {
  const StreakWeekCard({super.key, required this.summary});

  static const List<StreakDayStatus> _legendStatuses = [
    StreakDayStatus.completed,
    StreakDayStatus.partial,
    StreakDayStatus.missed,
  ];

  final StreakSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardHeader(
            title: 'This Week',
            titleStyle: AppTypography.heading4SemiBold,
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (final day in summary.days)
                Expanded(child: _DayColumn(day: day)),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final status in _legendStatuses) ...[
                if (status != _legendStatuses.first)
                  SizedBox(width: AppSpacing.lg),
                _LegendEntry(status: status, count: summary.countOf(status)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.day});

  final StreakDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.label,
          style: AppTypography.bodySmallSemiBold.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        StreakDayMarker(status: day.status),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.status, required this.count});

  final StreakDayStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreakDayMarker(status: status, size: AppSizes.s16),
        SizedBox(width: AppSpacing.xs),
        Text(
          '${status.label} ($count)',
          style: AppTypography.bodySmallMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

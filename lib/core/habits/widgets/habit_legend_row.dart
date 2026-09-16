import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_status_icon.dart';

class HabitLegendRow extends StatelessWidget {
  const HabitLegendRow({super.key, required this.items});

  final List<HabitLegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [for (final item in items) _LegendChip(item: item)],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.item});

  final HabitLegendItem item;

  static const double _partialProgress = 0.7;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HabitStatusIcon(
          status: item.status,
          progress: _partialProgress,
          size: AppSizes.s12,
          strokeWidth: AppSizes.s1,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          item.label,
          style: AppTypography.captionSemiBold.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

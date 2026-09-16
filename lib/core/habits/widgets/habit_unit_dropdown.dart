import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/core/habits/models/habit.dart';

class HabitUnitDropdown extends StatelessWidget {
  const HabitUnitDropdown({
    super.key,
    required this.metric,
    required this.metrics,
    required this.labelOf,
    required this.onSelected,
  });

  final HabitMetric metric;
  final List<HabitMetric> metrics;
  final String Function(HabitMetric metric) labelOf;
  final ValueChanged<HabitMetric> onSelected;

  void _select(HabitMetric value) {
    HapticManager.selection();
    onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<HabitMetric>(
      onSelected: _select,
      initialValue: metric,
      color: colors.backgroundElevated,
      elevation: 0,
      position: PopupMenuPosition.under,
      shape: AppShapes.border(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      itemBuilder: (context) => [
        for (final value in metrics)
          PopupMenuItem<HabitMetric>(
            value: value,
            height: AppSizes.s40,
            child: Text(
              labelOf(value),
              style: AppTypography.labelLargeMedium.copyWith(
                color: value == metric ? colors.primaryAlt : colors.textPrimary,
              ),
            ),
          ),
      ],
      child: Container(
        height: AppSizes.s40,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppShapes.decoration(
          color: colors.backgroundElevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(labelOf(metric), style: AppTypography.labelLargeMedium),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppSizes.s20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

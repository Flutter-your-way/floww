import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/widgets/habit_icon.dart';

class HabitStatTile extends StatelessWidget {
  const HabitStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  final HabitIconKind? icon;
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = this.icon;
    final unit = this.unit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              HabitIcon(
                kind: icon,
                size: AppSizes.s20,
                color: colors.textMuted,
              ),
              SizedBox(width: AppSpacing.md),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmallMediumTight.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyXLargeBold,
              ),
            ),
            if (unit != null) ...[
              SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  unit,
                  style: AppTypography.bodyXSmallRegular.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

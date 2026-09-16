import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class HabitConsistencyCard extends StatelessWidget {
  const HabitConsistencyCard({
    super.key,
    required this.title,
    required this.items,
    required this.strongestLabel,
    required this.weakestLabel,
    this.strongestHabit,
    this.weakestHabit,
  });

  final String title;
  final List<HabitConsistencyItem> items;
  final String strongestLabel;
  final String weakestLabel;
  final String? strongestHabit;
  final String? weakestHabit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strongestHabit = this.strongestHabit;
    final weakestHabit = this.weakestHabit;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.labelLargeSemiBold,
          ),
          if (strongestHabit != null && weakestHabit != null) ...[
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                HabitToneChip(
                  label: strongestLabel,
                  value: strongestHabit,
                  tint: colors.primary,
                  valueColor: colors.primaryAlt,
                  borderColor: colors.borderGlow,
                ),
                SizedBox(width: AppSpacing.md),
                HabitToneChip(
                  label: weakestLabel,
                  value: weakestHabit,
                  tint: colors.accentOrange,
                  valueColor: colors.accentOrangeDeep,
                  borderColor: colors.amberBorder,
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.xl),
          for (final item in items) ...[
            _HabitConsistencyRow(item: item),
            if (item != items.last) SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class HabitToneChip extends StatelessWidget {
  const HabitToneChip({
    super.key,
    required this.label,
    required this.value,
    required this.tint,
    required this.valueColor,
    required this.borderColor,
  });

  final String label;
  final String value;
  final Color tint;
  final Color valueColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: AppShapes.decoration(
        color: tint.withValues(alpha: AppOpacity.tintFill),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: borderColor, width: AppSizes.s1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.captionMediumMicro.copyWith(
              color: context.colors.textSubtle,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.captionSemiBoldMicro.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitConsistencyRow extends StatelessWidget {
  const _HabitConsistencyRow({required this.item});

  static const double _labelWidth = AppSizes.s64;

  final HabitConsistencyItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMediumSemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppProgressBar(
            progress: item.progress,
            height: AppSizes.s8,
            color: colors.primaryAlt,
            trackColor: colors.borderSubtle,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Text(
          '${item.completedDays}',
          style: AppTypography.bodyMediumMediumTight.copyWith(
            color: colors.textPrimary,
          ),
        ),
        Text(
          '/${item.targetDays}',
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

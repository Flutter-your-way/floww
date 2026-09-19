import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';

const String _flameEmoji = '🔥';

class HabitStreaksCard extends StatelessWidget {
  const HabitStreaksCard({super.key, required this.items});

  final List<HabitStreakItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Habit Streaks',
            titleStyle: AppTypography.heading4SemiBold,
          ),
          SizedBox(height: AppSpacing.xl),
          for (final item in items) ...[
            _StreakRow(item: item),
            Divider(
              height: AppSpacing.xl3,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.item});

  final HabitStreakItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            item.title,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelLargeSemiBold,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(_flameEmoji, style: AppTypography.bodyLargeSemiBoldTight),
        SizedBox(width: AppSpacing.xs),
        Text(
          item.daysLabel,
          style: AppTypography.bodyLargeSemiBoldTight.copyWith(
            color: colors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          'days',
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

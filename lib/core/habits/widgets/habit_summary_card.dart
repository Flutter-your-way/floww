import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/widgets/habit_stat_tile.dart';

class HabitSummaryCard extends StatelessWidget {
  const HabitSummaryCard({
    super.key,
    required this.bestStreakValue,
    required this.bestStreakUnit,
    required this.topHabitTitle,
  });

  final String bestStreakValue;
  final String bestStreakUnit;
  final String topHabitTitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: HabitStatTile(
                icon: HabitIconKind.flame,
                label: 'Best Streak',
                value: bestStreakValue,
                unit: bestStreakUnit,
              ),
            ),
            VerticalDivider(
              width: AppSpacing.xl3,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
            Expanded(
              child: HabitStatTile(
                icon: HabitIconKind.trophy,
                label: 'Top Habit',
                value: topHabitTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

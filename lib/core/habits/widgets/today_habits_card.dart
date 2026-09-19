import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_progress_row.dart';

class TodayHabitsCard extends StatelessWidget {
  const TodayHabitsCard({
    super.key,
    required this.title,
    required this.items,
    this.onToggle,
    this.onOpen,
  });

  final String title;
  final List<HabitRowItem> items;
  final void Function(HabitRowItem item)? onToggle;
  final void Function(HabitRowItem item)? onOpen;

  @override
  Widget build(BuildContext context) {
    final onToggle = this.onToggle;
    final onOpen = this.onOpen;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.heading4SemiBold,
          ),
          SizedBox(height: AppSpacing.xl),
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) SizedBox(height: AppSpacing.xl),
            HabitProgressRow(
              item: items[index],
              onToggle: onToggle == null ? null : () => onToggle(items[index]),
              onOpen: onOpen == null ? null : () => onOpen(items[index]),
            ),
          ],
        ],
      ),
    );
  }
}

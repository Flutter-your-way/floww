import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_suggestion_tile.dart';

class PopularHabitsCard extends StatelessWidget {
  const PopularHabitsCard({super.key, required this.items, this.onSelect});

  final List<HabitSuggestionItem> items;
  final void Function(HabitSuggestionItem item)? onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Popular Habits to Try',
            titleStyle: AppTypography.labelLargeSemiBold,
          ),
          SizedBox(height: AppSpacing.xl),
          HabitSuggestionGrid(items: items, onSelect: onSelect),
        ],
      ),
    );
  }
}

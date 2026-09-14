import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/home/widgets/home_card_empty_state.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class TodayHabitCard extends StatelessWidget {
  const TodayHabitCard({
    super.key,
    required this.habits,
    this.onCreateFirstHabit,
    this.onTap,
  });

  final List<HabitItem> habits;
  final VoidCallback? onCreateFirstHabit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completedCount = habits.where((h) => h.completed).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: "Today's Habit",
            trailingText: '$completedCount/${habits.length}',
            showChevron: true,
            onTap: onTap,
          ),
          SizedBox(height: AppSpacing.xl),
          if (habits.isEmpty)
            HomeCardEmptyState(
              icon: Icons.assignment_outlined,
              message:
                  'No habits set up yet. Create habits to build your daily plan.',
              buttonText: '+ CREATE FIRST HABIT',
              filled: true,
              onPressed: onCreateFirstHabit,
            )
          else
            for (var i = 0; i < habits.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.lg),
              _HabitRow(habit: habits[i]),
            ],
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit});

  final HabitItem habit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          habit.completed ? Icons.check_circle : Icons.circle_outlined,
          color: habit.completed
              ? context.colors.primary
              : context.colors.borderMedium,
          size: AppSizes.s24,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            habit.title,
            style: context.textTheme.bodyLarge?.copyWith(
              color: habit.completed ? context.colors.textSecondary : null,
              decoration: habit.completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Text(
          habit.valueLabel,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

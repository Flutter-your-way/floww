import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/widgets/habit_icon.dart';

class HabitsEmptyStateCard extends StatelessWidget {
  const HabitsEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    this.onCreateHabit,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onCreateHabit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.md),
          HabitIcon(
            kind: HabitIconKind.clipboard,
            size: AppSizes.s40,
            color: colors.textMuted,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.heading4SemiBold,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSubtle,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          PillButton(
            onPressed: onCreateHabit,
            variant: PillButtonVariant.bright,
            icon: Icons.add_rounded,
            iconColor: colors.onSurfaceBright,
            label: buttonLabel,
            labelStyle: AppTypography.labelMediumSemiBold,
          ),
        ],
      ),
    );
  }
}

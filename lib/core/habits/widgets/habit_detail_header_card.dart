import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_icon_tile.dart';
import 'package:floww/core/habits/widgets/habit_stat_grid.dart';

class HabitDetailHeaderCard extends StatelessWidget {
  const HabitDetailHeaderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.editLabel,
    required this.stats,
    this.onEdit,
  });

  final HabitIconKind icon;
  final String title;
  final String description;
  final String editLabel;
  final List<HabitStatItem> stats;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              HabitIconTile(icon: icon),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyXLargeBold,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              PillButton(
                variant: PillButtonVariant.neutral,
                label: editLabel,
                height: AppSizes.s36,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
                labelStyle: AppTypography.labelMediumSemiBold,
                onPressed: onEdit,
              ),
            ],
          ),
          Divider(
            height: AppSpacing.xl2,
            thickness: AppSizes.s1,
            color: colors.borderSubtle,
          ),
          HabitStatGrid(items: stats),
        ],
      ),
    );
  }
}

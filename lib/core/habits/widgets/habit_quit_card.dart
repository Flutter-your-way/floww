import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';

class HabitQuitCard extends StatelessWidget {
  const HabitQuitCard({
    super.key,
    required this.title,
    required this.dayLabel,
    required this.progress,
    required this.slipLabel,
    required this.actionLabel,
    required this.onAction,
    required this.isAchieved,
    required this.achievedTitle,
    required this.achievedMessage,
  });

  final String title;
  final String dayLabel;
  final double progress;
  final String slipLabel;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isAchieved;
  final String achievedTitle;
  final String achievedMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: isAchieved
          ? AppCardVariant.accentOutline
          : AppCardVariant.innerGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            icon: isAchieved ? Icons.emoji_events_rounded : Icons.block_rounded,
            trailingText: dayLabel,
          ),
          SizedBox(height: AppSpacing.lg),
          AppProgressBar(progress: progress, animated: true),
          SizedBox(height: AppSpacing.lg),
          if (isAchieved) ...[
            Text(
              achievedTitle,
              style: AppTypography.heading4SemiBold.copyWith(
                color: colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              achievedMessage,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: AppSizes.s16,
                color: colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  slipLabel,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          PillButton(
            variant: PillButtonVariant.neutral,
            label: actionLabel,
            icon: Icons.history_rounded,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

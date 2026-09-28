import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/effects/dashed_border.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/missed_workout_advice.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';
import 'package:floww/core/workout/widgets/workout_metric_row.dart';

class MissedWorkoutCard extends StatelessWidget {
  const MissedWorkoutCard({
    super.key,
    required this.missed,
    this.onTap,
    this.onAction,
    this.isActionLoading = false,
  });

  final MissedWorkoutItem missed;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionLabel = missed.actionLabel;
    final onAction = this.onAction;

    final card = DashedBorder(
      color: colors.destructiveOutline,
      radius: AppRadius.xl,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        missed.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading4SemiBold.copyWith(
                          color: colors.textSubtle,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        missed.dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                const WorkoutChip(
                  label: 'Missed',
                  icon: Icons.close_rounded,
                  tone: WorkoutChipTone.alert,
                ),
              ],
            ),
            if (missed.detailLabel.isNotEmpty) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                missed.detailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmallMedium.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.xl),
            WorkoutMetricRow(metrics: missed.metrics),
            SizedBox(height: AppSpacing.xl),
            MissedWorkoutAdvice(missed: missed),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.lg),
              PillButton(
                variant: PillButtonVariant.outline,
                height: AppSizes.s44,
                label: actionLabel,
                icon: Icons.event_repeat_rounded,
                isLoading: isActionLoading,
                onPressed: isActionLoading ? null : onAction,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return PressScale(onTap: onTap, child: card);
  }
}

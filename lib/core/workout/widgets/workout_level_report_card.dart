import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class WorkoutLevelReportCard extends StatelessWidget {
  const WorkoutLevelReportCard({
    super.key,
    required this.report,
    this.onLevelUp,
  });

  final WorkoutLevelReportItem report;
  final VoidCallback? onLevelUp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionLabel = report.actionLabel;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.verdictTitle,
                  style: AppTypography.heading4SemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              WorkoutChip(
                label: report.levelLabel,
                tone: report.isReady
                    ? WorkoutChipTone.accent
                    : WorkoutChipTone.muted,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            report.verdictMessage,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
          for (final period in report.periods) ...[
            SizedBox(height: AppSpacing.xl),
            _LevelPeriodRow(period: period),
          ],
          if (actionLabel != null && onLevelUp != null) ...[
            SizedBox(height: AppSpacing.xl),
            PillButton(
              height: AppSizes.s44,
              label: actionLabel,
              icon: Icons.trending_up_rounded,
              onPressed: onLevelUp,
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelPeriodRow extends StatelessWidget {
  const _LevelPeriodRow({required this.period});

  final WorkoutLevelPeriodItem period;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = period.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                period.label,
                style: AppTypography.labelLargeSemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text(
              period.sessionsLabel,
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.primaryAlt,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          SizedBox(height: AppSpacing.md),
          AppProgressBar(progress: progress, trackColor: colors.borderSubtle),
        ],
        SizedBox(height: AppSpacing.md),
        Text(
          '${period.volumeLabel} · ${period.effortLabel}',
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

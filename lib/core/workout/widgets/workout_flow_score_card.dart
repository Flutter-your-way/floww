import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';

class WorkoutFlowScoreCard extends StatelessWidget {
  const WorkoutFlowScoreCard({super.key, required this.summary});

  final WorkoutCompleteItem summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.innerGlow,
      borderColor: colors.borderAccent,
      radius: AppRadius.lg,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _FlowScoreProgress(summary: summary)),
          SizedBox(width: AppSpacing.xl),
          Container(
            width: AppSizes.s1,
            height: AppSizes.s44,
            color: colors.borderMedium,
          ),
          SizedBox(width: AppSpacing.xl),
          _FlowScoreGain(summary: summary),
        ],
      ),
    );
  }
}

class _FlowScoreProgress extends StatelessWidget {
  const _FlowScoreProgress({required this.summary});

  final WorkoutCompleteItem summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: AppSizes.s20, color: colors.textPrimary),
            SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                summary.scoreLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLargeSemiBold.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              summary.previousScoreLabel,
              style: AppTypography.heading3Bold.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.s20,
              color: colors.primary,
            ),
            SizedBox(width: AppSpacing.md),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  summary.newScoreLabel,
                  maxLines: 1,
                  style: AppTypography.heading2ExtraBold.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlowScoreGain extends StatelessWidget {
  const _FlowScoreGain({required this.summary});

  final WorkoutCompleteItem summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: AppShapes.decoration(
            color: colors.bgTinted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
          ),
          child: Text(
            summary.gainLabel,
            style: AppTypography.bodySmallSemiBold.copyWith(
              color: colors.primary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          summary.gainCaption,
          style: AppTypography.captionMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

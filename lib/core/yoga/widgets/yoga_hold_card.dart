import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_ring.dart';
import 'package:floww/core/yoga/models/yoga_class_view_data.dart';

class YogaHoldCard extends StatelessWidget {
  const YogaHoldCard({
    super.key,
    required this.holdLabel,
    required this.progress,
    required this.isPaused,
    required this.breathCue,
    this.step,
  });

  static const double _ringSize = AppSizes.s160;
  static const double _ringStroke = AppSizes.s10;

  final String holdLabel;
  final double progress;
  final bool isPaused;
  final String breathCue;
  final YogaStepItem? step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final step = this.step;

    return AppCard(
      variant: AppCardVariant.sunken,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        children: [
          AppProgressRing(
            progress: progress,
            size: _ringSize,
            strokeWidth: _ringStroke,
            gradient: context.gradients.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  holdLabel,
                  style: AppTypography.heading1.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  isPaused ? 'Paused' : 'Hold',
                  style: AppTypography.captionSemiBold.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (step != null) ...[
            SizedBox(height: AppSpacing.xl2),
            Text(
              step.counterLabel.toUpperCase(),
              style: AppTypography.labelSmallSemiBold.copyWith(
                color: colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: AppTypography.heading4SemiBold.copyWith(
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              step.instruction,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMediumRegular.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xl2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air_rounded,
                size: AppSizes.s16,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  breathCue,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveScoreReportCard extends StatelessWidget {
  const WaveScoreReportCard({
    super.key,
    required this.report,
    required this.onLogMeal,
    required this.onLogWater,
  });

  final WaveScoreReport report;
  final VoidCallback onLogMeal;
  final VoidCallback onLogWater;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const WaveSectionLabel(label: 'YOUR FLOW SCORE'),
                SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${report.score}',
                      style: AppTypography.bodyXXLargeBold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: AppSizes.s12,
                            color: context.colors.accentOrangeLight,
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            report.potentialLabel,
                            style: AppTypography.bodySmallSemiBold.copyWith(
                              color: context.colors.accentOrangeLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              report.summary,
              textAlign: TextAlign.right,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSubtle,
              ),
            ),
          ),
        ],
      ),
      sections: [
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final factor in report.factors) ...[
                if (factor != report.factors.first)
                  SizedBox(height: AppSpacing.lg),
                _ScoreFactorRow(factor: factor),
              ],
            ],
          ),
        ),
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WaveSectionLabel(label: 'QUICK FIXES'),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.neutral,
                      label: 'Log Meal',
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyMediumBold,
                      labelColor: context.colors.primary,
                      onPressed: onLogMeal,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.neutral,
                      label: 'Log Water',
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyMediumBold,
                      labelColor: context.colors.primary,
                      onPressed: onLogWater,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreFactorRow extends StatelessWidget {
  const _ScoreFactorRow({required this.factor});

  final WaveScoreFactor factor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(factor.icon, size: AppSizes.s18, color: colors.textDim),
            SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                factor.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMediumBold.copyWith(
                  color: factor.isLow ? colors.textPrimary : colors.textSubtle,
                ),
              ),
            ),
            if (factor.isLow) ...[
              SizedBox(width: AppSpacing.md),
              const _LowFactorChip(),
            ],
            const Spacer(),
            Text('${factor.value}', style: AppTypography.bodyMediumBold),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(progress: factor.fraction, height: AppSizes.s4),
      ],
    );
  }
}

class _LowFactorChip extends StatelessWidget {
  const _LowFactorChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.destructiveTint,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: context.colors.destructiveOutline,
          width: AppSizes.s1,
        ),
      ),
      child: Text(
        'LOW',
        style: AppTypography.bodyXSmallSemiBold.copyWith(
          color: context.colors.destructiveBorder,
        ),
      ),
    );
  }
}

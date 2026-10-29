import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/strength_view_data.dart';
import 'package:floww/core/progress/widgets/weight_line_chart.dart';

class StrengthMuscleCard extends StatelessWidget {
  const StrengthMuscleCard({
    super.key,
    required this.muscle,
    required this.emptyValueLabel,
    required this.addLabel,
    required this.logAgainLabel,
    required this.onTap,
  });

  final StrengthMuscleView muscle;
  final String emptyValueLabel;
  final String addLabel;
  final String logAgainLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: muscle.title,
              icon: Icons.fitness_center_rounded,
              trailing: muscle.hasData
                  ? AppStatusChip(
                      label: muscle.levelLabel,
                      variant: AppStatusChipVariant.outlined,
                    )
                  : null,
            ),
            SizedBox(height: AppSpacing.xl),
            if (muscle.hasData)
              _StrengthDetail(
                muscle: muscle,
                logAgainLabel: logAgainLabel,
                onLog: onTap,
              )
            else
              _EmptyStrength(valueLabel: emptyValueLabel, addLabel: addLabel),
          ],
        ),
      ),
    );
  }
}

class _EmptyStrength extends StatelessWidget {
  const _EmptyStrength({required this.valueLabel, required this.addLabel});

  final String valueLabel;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Text(
          valueLabel,
          style: context.textTheme.displayMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          addLabel,
          style: context.textTheme.bodyMedium?.copyWith(color: colors.primary),
        ),
      ],
    );
  }
}

class _StrengthDetail extends StatelessWidget {
  const _StrengthDetail({
    required this.muscle,
    required this.logAgainLabel,
    required this.onLog,
  });

  final StrengthMuscleView muscle;
  final String logAgainLabel;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chart = muscle.chart;
    final changeLabel = muscle.changeLabel;
    final trendHint = muscle.trendHint;
    final changeColor = switch (muscle.isImproving) {
      true => colors.success,
      false => colors.destructive,
      null => colors.textSecondary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(muscle.valueLabel, style: context.textTheme.displayMedium),
            Text(
              muscle.unitLabel,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            if (changeLabel != null)
              Expanded(
                child: Text(
                  changeLabel,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          muscle.exerciseLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (chart != null) ...[
          SizedBox(height: AppSpacing.xl),
          WeightLineChart(
            samples: chart.samples,
            axisLabels: chart.axisLabels,
            dateLabels: chart.dateLabels,
            minValue: chart.minValue,
            maxValue: chart.maxValue,
            plotHeight: AppSizes.s120,
          ),
        ],
        SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                trendHint ?? '',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            PillButton(
              variant: PillButtonVariant.glass,
              height: AppSizes.s32,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              label: logAgainLabel,
              labelStyle: AppTypography.bodySmallSemiBold,
              labelColor: colors.primary,
              onPressed: onLog,
            ),
          ],
        ),
      ],
    );
  }
}

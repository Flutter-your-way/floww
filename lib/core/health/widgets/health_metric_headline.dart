import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';

class HealthMetricHeadline extends StatelessWidget {
  const HealthMetricHeadline({
    super.key,
    required this.value,
    required this.unit,
    required this.dateLabel,
    required this.sourceLabel,
    required this.trend,
    this.isImproving,
    this.changeLabel,
  });

  final String value;
  final String unit;
  final String dateLabel;
  final String sourceLabel;
  final HealthTrend trend;
  final bool? isImproving;
  final String? changeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final changeLabel = this.changeLabel;
    final changeColor = switch (isImproving) {
      true => colors.success,
      false => colors.destructive,
      null => colors.textSecondary,
    };

    return AppCard(
      variant: AppCardVariant.glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: context.textTheme.displayMedium),
              if (unit.isNotEmpty) ...[
                SizedBox(width: AppSpacing.sm),
                Text(
                  unit,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (changeLabel != null) ...[
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  trend == HealthTrend.up
                      ? Icons.north_east_rounded
                      : Icons.south_east_rounded,
                  size: AppSizes.s16,
                  color: changeColor,
                ),
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    changeLabel,
                    style: AppTypography.bodySmallSemiBold.copyWith(
                      color: changeColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          Text(
            sourceLabel,
            style: AppTypography.captionMediumSmall.copyWith(
              color: colors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

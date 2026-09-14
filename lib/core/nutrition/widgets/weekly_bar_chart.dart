import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/config/theme/app_shapes.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.bars,
    required this.color,
    this.barAreaHeight = AppSizes.s96,
  });

  final List<ChartBar> bars;
  final Color color;
  final double barAreaHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = bars.fold<double>(
      0,
      (current, bar) => math.max(current, bar.value),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final bar in bars)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  Text(
                    bar.valueLabel ?? '',
                    maxLines: 1,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  SizedBox(
                    height: barAreaHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: maxValue == 0
                            ? 0
                            : (bar.value / maxValue).clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: AppShapes.decoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.sm),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    bar.label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: bar.isHighlighted
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

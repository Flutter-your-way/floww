import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class WorkoutMetricRow extends StatelessWidget {
  const WorkoutMetricRow({super.key, required this.metrics});

  final List<WorkoutMetricItem> metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.xl2),
          Flexible(child: _WorkoutMetric(metric: metrics[i])),
        ],
      ],
    );
  }
}

class _WorkoutMetric extends StatelessWidget {
  const _WorkoutMetric({required this.metric});

  final WorkoutMetricItem metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(metric.icon, size: AppSizes.s16, color: colors.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

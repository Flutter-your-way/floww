import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/home/models/home_view_data.dart';

class RecoveryMetricRow extends StatelessWidget {
  const RecoveryMetricRow({super.key, required this.metric, this.onInfoTap});

  final RecoveryMetric metric;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(metric.emoji, style: context.textTheme.bodyLarge),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricLabel(label: metric.label, onInfoTap: onInfoTap),
            ),
            Text(
              metric.valueLabel,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              metric.hasData ? '${metric.percent}%' : '–',
              style: context.textTheme.labelLarge?.copyWith(
                color: metric.hasData
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppProgressBar(
          progress: metric.percent / 100,
          height: AppSizes.s8,
          trackColor: context.colors.backgroundElevated,
        ),
      ],
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.label, this.onInfoTap});

  final String label;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, style: context.textTheme.titleLarge);
    final onInfoTap = this.onInfoTap;
    if (onInfoTap == null) return text;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onInfoTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            text,
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.info_outline_rounded,
              size: AppSizes.s16,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

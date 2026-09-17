import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/home/models/home_view_data.dart';

class RecoveryMetricRow extends StatelessWidget {
  const RecoveryMetricRow({super.key, required this.metric});

  final RecoveryMetric metric;

  Color _accentColor(BuildContext context) {
    return switch (metric.accent) {
      RecoveryMetricAccent.sleep => context.colors.accentViolet,
      RecoveryMetricAccent.hrv => context.colors.success,
      RecoveryMetricAccent.energy => context.colors.accentOrange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(metric.emoji, style: context.textTheme.bodyLarge),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(metric.label, style: context.textTheme.titleLarge),
            ),
            Text(
              metric.valueLabel,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text('${metric.percent}%', style: context.textTheme.labelLarge),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppProgressBar(
          progress: metric.percent / 100,
          height: AppSizes.s8,
          color: accent,
          trackColor: context.colors.backgroundElevated,
        ),
      ],
    );
  }
}

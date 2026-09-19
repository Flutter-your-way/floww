import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/config/widgets/stats/app_stat_column.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/widgets/recovery_metric_row.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class RecoverySheet extends StatelessWidget {
  const RecoverySheet({super.key, required this.detail});

  final RecoveryDetail detail;

  static Future<void> show(
    BuildContext context, {
    required RecoveryDetail detail,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => RecoverySheet(detail: detail),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = detail.metrics;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Recovery',
        closeButtonSize: AppSizes.s32,
        closeIconSize: AppSizes.s16,
        onClose: () => NavigationService.instance.pop(),
        leading: AppIconTile(
          icon: Icons.favorite_rounded,
          size: AppSizes.s44,
          iconSize: AppSizes.s24,
          radius: AppRadius.md,
          backgroundColor: context.colors.tint,
          borderColor: context.colors.borderGlow,
          iconColor: context.colors.primary,
        ),
        titleContent: _RecoveryTitle(
          percent: detail.percent,
          levelLabel: detail.levelLabel,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (metrics.isEmpty)
              Text(
                'Connect Apple Health or Health Connect to see your sleep, '
                'HRV and energy.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.xl),
              RecoveryMetricRow(metric: metrics[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecoveryTitle extends StatelessWidget {
  const _RecoveryTitle({required this.percent, required this.levelLabel});

  final int percent;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppStatLabel(label: 'RECOVERY'),
        SizedBox(height: AppSpacing.xxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$percent', style: context.textTheme.headlineSmall),
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(
                '%',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                width: AppSizes.s1,
                height: AppSizes.s16,
                color: colors.borderSubtle,
              ),
            ),
            AppStatValue(
              value: levelLabel,
              dotColor: colors.success,
              valueColor: colors.success,
            ),
          ],
        ),
      ],
    );
  }
}

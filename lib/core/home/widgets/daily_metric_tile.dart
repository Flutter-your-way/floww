import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';

class DailyMetricTileCard extends StatelessWidget {
  const DailyMetricTileCard({super.key, required this.tile, this.onTap});

  final DailyMetricTile tile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: AppShapes.decoration(
          color: colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tile.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizes.s16,
                    color: colors.textMuted,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.xxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  tile.value,
                  style: AppTypography.bodyLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (tile.unit.isNotEmpty) ...[
                  SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      tile.unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (tile.showsTrend) _TrendArrow(tile: tile),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.tile});

  final DailyMetricTile tile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (tile.tone) {
      DailyMetricTone.positive => colors.success,
      DailyMetricTone.negative => colors.destructive,
      DailyMetricTone.neutral => colors.textSecondary,
    };

    return Icon(
      tile.trend == HealthTrend.up
          ? Icons.arrow_drop_up_rounded
          : Icons.arrow_drop_down_rounded,
      size: AppSizes.s24,
      color: color,
    );
  }
}

class DailyMetricGrid extends StatelessWidget {
  const DailyMetricGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index += 2) ...[
          if (index > 0) SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[index]),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: index + 1 < children.length
                      ? children[index + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

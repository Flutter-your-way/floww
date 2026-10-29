import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';

class DailyMetricTileCard extends StatelessWidget {
  const DailyMetricTileCard({super.key, required this.tile});

  final DailyMetricTile tile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tile.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
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
                SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    tile.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
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
      size: AppSizes.s28,
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
          if (index > 0) SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[index]),
                SizedBox(width: AppSpacing.lg),
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

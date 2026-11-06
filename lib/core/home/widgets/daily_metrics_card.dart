import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/health/models/health_metric_kind.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';
import 'package:floww/core/home/widgets/daily_metric_tile.dart';

class DailyMetricsCard extends StatelessWidget {
  const DailyMetricsCard({
    super.key,
    required this.data,
    required this.onInfoTap,
    required this.onCustomizeTap,
    required this.onMetricTap,
    required this.onBodyCompositionTap,
  });

  final DailyMetricsViewData data;
  final VoidCallback onInfoTap;
  final VoidCallback onCustomizeTap;
  final ValueChanged<HealthMetricKind> onMetricTap;
  final VoidCallback onBodyCompositionTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: data.title,
            titleStyle: context.textTheme.titleLarge,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.canCustomize) ...[
                  _HeaderIconButton(
                    icon: Icons.tune_rounded,
                    onTap: onCustomizeTap,
                  ),
                  SizedBox(width: AppSpacing.lg),
                ],
                _HeaderIconButton(
                  icon: Icons.info_outline_rounded,
                  onTap: onInfoTap,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          DailyMetricGrid(
            children: [
              for (final tile in data.tiles)
                DailyMetricTileCard(
                  tile: tile,
                  onTap: () => onMetricTap(tile.kind),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _BodyCompositionLink(
            label: data.bodyCompositionLabel,
            onTap: onBodyCompositionTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: AppSizes.s20,
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _BodyCompositionLink extends StatelessWidget {
  const _BodyCompositionLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(
            Icons.arrow_forward_rounded,
            size: AppSizes.s16,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

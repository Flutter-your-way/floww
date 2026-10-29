import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';
import 'package:floww/core/home/widgets/daily_metric_tile.dart';

class DailyMetricsCard extends StatelessWidget {
  const DailyMetricsCard({
    super.key,
    required this.data,
    required this.onInfoTap,
    required this.onBodyCompositionTap,
  });

  final DailyMetricsViewData data;
  final VoidCallback onInfoTap;
  final VoidCallback onBodyCompositionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: data.title,
            titleStyle: context.textTheme.titleLarge,
            trailing: GestureDetector(
              onTap: onInfoTap,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.info_outline_rounded,
                size: AppSizes.s20,
                color: colors.textSecondary,
              ),
            ),
          ),
          for (final section in data.sections) ...[
            SizedBox(height: AppSpacing.xl),
            Text(
              section.title,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            DailyMetricGrid(
              children: [
                for (final tile in section.tiles)
                  DailyMetricTileCard(tile: tile),
                if (section.kind == DailyMetricSectionKind.body)
                  _BodyCompositionLink(
                    label: data.bodyCompositionLabel,
                    onTap: onBodyCompositionTap,
                  ),
              ],
            ),
          ],
        ],
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.s20,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

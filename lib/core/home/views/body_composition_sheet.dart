import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';
import 'package:floww/core/home/widgets/daily_metric_tile.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class BodyCompositionSheet extends StatelessWidget {
  const BodyCompositionSheet({super.key, required this.data});

  static Future<void> show(
    BuildContext context, {
    required BodyCompositionViewData data,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => BodyCompositionSheet(data: data),
    );
  }

  final BodyCompositionViewData data;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: data.title,
        subtitle: data.subtitle,
        titleStyle: AppTypography.heading3SemiBold,
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DailyMetricGrid(
              children: [
                for (final tile in data.tiles) DailyMetricTileCard(tile: tile),
              ],
            ),
            if (!data.hasData) ...[
              SizedBox(height: AppSpacing.xl),
              Text(
                data.emptyMessage,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

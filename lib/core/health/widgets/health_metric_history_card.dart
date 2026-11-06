import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/health/view_models/health_metric_detail_view_model.dart';

class HealthMetricHistoryCard extends StatelessWidget {
  const HealthMetricHistoryCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<HealthMetricHistoryRow> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: context.textTheme.titleLarge),
          SizedBox(height: AppSpacing.md),
          for (final row in rows) ...[
            if (row != rows.first)
              Divider(
                height: AppSpacing.xl,
                thickness: AppSizes.s1,
                color: context.colors.borderSubtle,
              ),
            _HistoryRow(row: row),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.row});

  final HealthMetricHistoryRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            row.dateLabel,
            style: context.textTheme.bodyMedium?.copyWith(
              color: row.isLatest ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          row.valueLabel,
          style: AppTypography.bodyMediumSemiBold.copyWith(
            color: row.isLatest ? colors.primary : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

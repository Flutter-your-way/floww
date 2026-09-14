import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class FlowPointsRowList extends StatelessWidget {
  const FlowPointsRowList({super.key, required this.rows});

  final List<FlowPointRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: _FlowPointsRow(row: row),
          ),
      ],
    );
  }
}

class _FlowPointsRow extends StatelessWidget {
  const _FlowPointsRow({required this.row});

  final FlowPointRow row;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(row.label, style: context.textTheme.bodySmall),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                row.detail,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              row.pointsLabel,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(progress: row.progress),
      ],
    );
  }
}

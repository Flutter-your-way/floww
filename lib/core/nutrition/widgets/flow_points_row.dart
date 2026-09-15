import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class FlowPointsRowList extends StatelessWidget {
  const FlowPointsRowList({
    super.key,
    required this.rows,
    this.showDividers = false,
  });

  final List<FlowPointRow> rows;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (showDividers && i > 0)
            Divider(
              height: AppSizes.s1,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : AppSpacing.lg,
              bottom: i == rows.length - 1 ? 0 : AppSpacing.lg,
            ),
            child: _FlowPointsRow(row: rows[i]),
          ),
        ],
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
            Text(
              row.label,
              style: AppTypography.labelSmallMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                row.detail,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionMedium.copyWith(
                  color: context.colors.textFaint,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Text(
              row.pointsLabel,
              style: AppTypography.bodySmallMediumTight.copyWith(
                color: context.colors.primaryAlt,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppProgressBar(
          progress: row.progress,
          height: AppSizes.s4,
          trackColor: context.colors.borderSubtle,
        ),
      ],
    );
  }
}

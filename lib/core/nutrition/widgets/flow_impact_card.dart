import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/flow_points_row.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FlowImpactCard extends StatelessWidget {
  const FlowImpactCard({
    super.key,
    required this.totalPointsLabel,
    required this.maxLabel,
    required this.rows,
  });

  final String totalPointsLabel;
  final String maxLabel;
  final List<FlowPointRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded, color: colors.primary, size: AppSizes.s20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'How this day\'s nutrition contributed to your Flow Score',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppShapes.decoration(
              color: colors.tint,
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: colors.borderGlow),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max possible from nutrition:',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        maxLabel,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalPointsLabel,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Flow Points',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          FlowPointsRowList(rows: rows),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
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

  static const String _title =
      'How this day\'s nutrition contributed to Flow Score Impact';
  static const String _bolt = '⚡';

  final String totalPointsLabel;
  final String maxLabel;
  final List<FlowPointRow> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(_bolt, style: AppTypography.labelLargeSemiBold),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _title,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          _FlowImpactSummary(
            maxLabel: maxLabel,
            totalPointsLabel: totalPointsLabel,
          ),
          if (rows.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xl),
            FlowPointsRowList(rows: rows, showDividers: true),
          ],
        ],
      ),
    );
  }
}

class _FlowImpactSummary extends StatelessWidget {
  const _FlowImpactSummary({
    required this.maxLabel,
    required this.totalPointsLabel,
  });

  static const String _maxPrefix = 'Max possible from nutrition:\n';
  static const String _maxSuffix = ' per day';
  static const String _pointsLabel = 'Flow Points';

  final String maxLabel;
  final String totalPointsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderGlow),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTypography.labelSmallRegular.copyWith(
                  color: colors.textPrimary,
                ),
                children: [
                  const TextSpan(text: _maxPrefix),
                  TextSpan(
                    text: maxLabel,
                    style: AppTypography.labelSmallMedium.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const TextSpan(text: _maxSuffix),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: AppSizes.s1,
            height: AppSizes.s40,
            child: ColoredBox(color: colors.borderMedium),
          ),
          SizedBox(width: AppSpacing.lg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalPointsLabel,
                style: AppTypography.bodyXLargeBold.copyWith(
                  color: colors.primary,
                ),
              ),
              Text(
                _pointsLabel,
                style: AppTypography.bodySmallMediumTight.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

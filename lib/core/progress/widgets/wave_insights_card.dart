import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class WaveInsightsCard extends StatelessWidget {
  const WaveInsightsCard({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.insights,
    required this.improvementLabel,
    required this.weaknessLabel,
  });

  final String title;
  final String rangeLabel;
  final WaveInsights insights;
  final String improvementLabel;
  final String weaknessLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            icon: Icons.bolt,
            iconColor: colors.primary,
            iconSize: AppSizes.s16,
            titleStyle: AppTypography.heading4SemiBold,
            trailing: Text(
              rangeLabel,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _InsightTile(
                    icon: Icons.trending_up_rounded,
                    label: improvementLabel,
                    value: insights.improvement,
                    tint: colors.primary,
                    labelColor: colors.primaryAlt,
                    borderColor: colors.borderGlow,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _InsightTile(
                    icon: Icons.trending_down_rounded,
                    label: weaknessLabel,
                    value: insights.weakness,
                    tint: colors.accentOrange,
                    labelColor: colors.accentOrangeDeep,
                    borderColor: colors.amberBorder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.labelColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color labelColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: tint.withValues(alpha: AppOpacity.tintFill),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: borderColor, width: AppSizes.s1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.s12, color: tint),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSemiBoldMicro.copyWith(
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelLargeSemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

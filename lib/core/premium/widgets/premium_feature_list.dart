import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/widgets/premium_feature_tone_color.dart';

class PremiumFeatureList extends StatelessWidget {
  const PremiumFeatureList({super.key, required this.features});

  final List<PremiumFeature> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final feature in features) ...[
          Divider(
            height: AppSpacing.xl2,
            thickness: AppSizes.s1,
            color: context.colors.borderSubtle,
          ),
          _PremiumFeatureRow(feature: feature),
        ],
      ],
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  const _PremiumFeatureRow({required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        AppIconTile(
          icon: feature.icon,
          iconColor: feature.tone.resolve(context),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                feature.description,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

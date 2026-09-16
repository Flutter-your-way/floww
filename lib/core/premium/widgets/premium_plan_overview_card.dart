import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/widgets/premium_feature_list.dart';

class PremiumPlanOverviewCard extends StatelessWidget {
  const PremiumPlanOverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.features,
  });

  static const IconData crownIcon = Icons.workspace_premium_rounded;

  final String title;
  final String subtitle;
  final List<PremiumFeature> features;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIconTile(
                icon: crownIcon,
                size: AppSizes.s72,
                iconSize: AppSizes.s36,
                radius: AppRadius.lg,
                backgroundColor: colors.bgTinted,
                borderColor: colors.borderGlow,
                iconColor: colors.primary,
              ),
              SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading3Bold,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.bodyLargeMedium.copyWith(
                        color: colors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PremiumFeatureList(features: features),
        ],
      ),
    );
  }
}

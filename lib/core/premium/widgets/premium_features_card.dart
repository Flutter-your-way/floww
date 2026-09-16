import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/premium/models/premium_view_data.dart';
import 'package:floww/core/premium/widgets/premium_feature_list.dart';

class PremiumFeaturesCard extends StatelessWidget {
  const PremiumFeaturesCard({
    super.key,
    required this.title,
    required this.features,
  });

  final String title;
  final List<PremiumFeature> features;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.accentOutline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: AppTypography.heading3Bold),
          PremiumFeatureList(features: features),
        ],
      ),
    );
  }
}

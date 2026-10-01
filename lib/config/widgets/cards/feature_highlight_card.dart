import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/entities/feature_highlight.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/feature_highlight_row.dart';
import 'package:flutter/material.dart';

class FeatureHighlightCard extends StatelessWidget {
  const FeatureHighlightCard({super.key, required this.highlights});

  final List<FeatureHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.innerGlow,
      child: Column(
        children: [
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.xl),
            FeatureHighlightRow(highlight: highlights[i]),
          ],
        ],
      ),
    );
  }
}

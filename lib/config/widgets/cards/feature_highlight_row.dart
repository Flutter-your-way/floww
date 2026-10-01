import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/entities/feature_highlight.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:flutter/material.dart';

class FeatureHighlightRow extends StatelessWidget {
  const FeatureHighlightRow({super.key, required this.highlight});

  final FeatureHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconTile(
          icon: highlight.icon,
          size: AppSizes.s40,
          iconSize: AppSizes.s20,
          backgroundColor: context.colors.tint,
          borderColor: context.colors.borderGlow,
          iconColor: context.colors.primary,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(highlight.title, style: context.textTheme.titleSmall),
              SizedBox(height: AppSpacing.xxs),
              Text(
                highlight.description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

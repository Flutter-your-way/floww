import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';

class YogaCourseHeroCard extends StatelessWidget {
  const YogaCourseHeroCard({
    super.key,
    required this.brand,
    required this.title,
    required this.subtitle,
    required this.motto,
    required this.pillars,
  });

  final String brand;
  final String title;
  final String subtitle;
  final String motto;
  final List<YogaPillarItem> pillars;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.glow,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand,
            style: AppTypography.labelLargeSemiBold.copyWith(
              color: colors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.heading2Bold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypography.bodySmallMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              for (var i = 0; i < pillars.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                Expanded(child: _PillarTile(pillar: pillars[i])),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            motto,
            style: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({required this.pillar});

  final YogaPillarItem pillar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.sunken,
      radius: AppRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            pillar.name.toUpperCase(),
            style: AppTypography.labelSmallSemiBold.copyWith(
              color: colors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            pillar.meaning,
            textAlign: TextAlign.center,
            style: AppTypography.captionMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

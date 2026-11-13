import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class ProgramCollectionCard extends StatelessWidget {
  const ProgramCollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  final ProgramCollectionItem collection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        variant: AppCardVariant.glow,
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title.toUpperCase(),
                    style: AppTypography.photoCardTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    collection.subtitle,
                    style: AppTypography.bodyMediumRegular.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.s28,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

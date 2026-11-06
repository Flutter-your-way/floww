import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class NutritionLinkCard extends StatelessWidget {
  const NutritionLinkCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: AppCardVariant.tinted,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading4SemiBold.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: context.colors.textSecondary,
                        size: AppSizes.s12,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmallMediumTight.copyWith(
                            color: context.colors.textSubtle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.xl),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textSecondary,
              size: AppSizes.s16,
            ),
          ],
        ),
      ),
    );
  }
}

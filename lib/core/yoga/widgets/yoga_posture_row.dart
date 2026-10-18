import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';

class YogaPostureRow extends StatelessWidget {
  const YogaPostureRow({super.key, required this.posture, required this.onTap});

  static const double _thumbnailSize = AppSizes.s56;

  final YogaPostureRowItem posture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sanskritName = posture.sanskritName;

    return PressScale(
      onTap: onTap,
      child: AppCard(
        variant: AppCardVariant.subtle,
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox.square(
                dimension: _thumbnailSize,
                child: RemoteImage(
                  url: posture.imageUrl,
                  fallbackIcon: Icons.self_improvement,
                  fallbackIconSize: AppSizes.s24,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    posture.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMediumSemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  if (sanskritName != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      sanskritName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmallMedium.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (posture.isCautioned) ...[
              SizedBox(width: AppSpacing.md),
              Icon(
                Icons.health_and_safety_outlined,
                size: AppSizes.s20,
                color: colors.warning,
              ),
            ],
            SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.s20,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

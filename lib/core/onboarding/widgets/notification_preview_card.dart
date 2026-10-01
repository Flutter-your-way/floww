import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

import '../providers/notification_permission_provider.dart';

class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({
    super.key,
    required this.appName,
    required this.preview,
  });

  final String appName;
  final NotificationPreview preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.lg,
          children: [
            ClipRSuperellipse(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                AppImages.appIcon,
                width: AppSizes.s36,
                height: AppSizes.s36,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xxs,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appName,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.textFaint,
                          ),
                        ),
                      ),
                      Text(
                        preview.timeLabel,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textFaint,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    preview.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMediumSemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    preview.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

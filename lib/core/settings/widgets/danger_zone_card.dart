import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class DangerZoneCard extends StatelessWidget {
  const DangerZoneCard({
    super.key,
    required this.title,
    required this.actionTitle,
    required this.actionSubtitle,
    this.onDelete,
  });

  final String title;
  final String actionTitle;
  final String actionSubtitle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: AppTypography.heading4),
          SizedBox(height: AppSpacing.xl),
          PressScale(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: AppShapes.decoration(
                color: colors.destructiveTint,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(
                  color: colors.destructiveOutline,
                  width: AppSizes.s1,
                ),
              ),
              child: Row(
                children: [
                  AppIconTile(
                    icon: Icons.delete_outline_rounded,
                    backgroundColor: colors.destructiveTint,
                    borderColor: colors.destructiveOutline,
                    iconColor: colors.destructiveBorder,
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionTitle,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                            color: colors.destructiveBorder,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          actionSubtitle,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMediumMedium.copyWith(
                            color: colors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizes.s20,
                    color: colors.destructiveBorder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

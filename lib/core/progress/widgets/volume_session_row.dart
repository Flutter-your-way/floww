import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class VolumeSessionRow extends StatelessWidget {
  const VolumeSessionRow({super.key, required this.item});

  final VolumeSessionItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  item.dateLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.setsLabel,
                style: AppTypography.labelLargeSemiBold.copyWith(
                  color: colors.primaryAlt,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                item.volumeLabel,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

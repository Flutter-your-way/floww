import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';

class ShareStatTile extends StatelessWidget {
  const ShareStatTile({super.key, required this.stat});

  final ShareStatItem stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glyph = stat.glyph;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMediumMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      text: stat.value,
                      children: glyph == null
                          ? null
                          : [
                              WidgetSpan(child: SizedBox(width: AppSpacing.sm)),
                              TextSpan(
                                text: glyph,
                                style: AppTypography.heading1,
                              ),
                            ],
                    ),
                    maxLines: 1,
                    style: AppTypography.bodyXXLargeBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (stat.unit.isNotEmpty) ...[
                SizedBox(width: AppSpacing.xs),
                Text(
                  stat.unit,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

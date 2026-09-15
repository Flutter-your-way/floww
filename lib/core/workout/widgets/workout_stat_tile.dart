import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';

class WorkoutStatTile extends StatelessWidget {
  const WorkoutStatTile({super.key, required this.stat, this.titleStyle});

  final WorkoutStatItem stat;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(stat.icon, size: AppSizes.s16, color: colors.textSecondary),
            SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                stat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    titleStyle ??
                    AppTypography.captionSemiBold.copyWith(
                      color: colors.textSubtle,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  maxLines: 1,
                  style: AppTypography.bodyXLargeBold.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            if (stat.unit.isNotEmpty) ...[
              SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    stat.unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyXSmallRegular.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

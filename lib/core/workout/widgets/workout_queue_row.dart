import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';

class WorkoutQueueRow extends StatelessWidget {
  const WorkoutQueueRow({
    super.key,
    required this.item,
    required this.dragHandle,
    this.onTap,
  });

  final ActiveQueueItem item;
  final Widget dragHandle;
  final VoidCallback? onTap;

  IconData get _statusIcon => switch (item.status) {
    ActiveQueueStatus.done => Icons.check_circle_rounded,
    ActiveQueueStatus.skipped => Icons.skip_next_rounded,
    ActiveQueueStatus.current => Icons.play_circle_fill_rounded,
    ActiveQueueStatus.pending => Icons.radio_button_unchecked,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCurrent = item.status == ActiveQueueStatus.current;
    final isDone = item.status == ActiveQueueStatus.done;
    final groupLabel = item.groupLabel;

    return PressScale(
      onTap: isDone ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: AppShapes.decoration(
          color: isCurrent ? colors.bgTinted : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: isCurrent
              ? BorderSide(color: colors.primary, width: AppSizes.s1)
              : BorderSide.none,
        ),
        child: Row(
          children: [
            Icon(
              _statusIcon,
              size: AppSizes.s20,
              color: isDone || isCurrent ? colors.primary : colors.textFaint,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMediumSemiBold.copyWith(
                      color: isDone ? colors.textSecondary : colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    groupLabel == null
                        ? item.detailLabel
                        : '$groupLabel · ${item.detailLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyXSmallMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            dragHandle,
          ],
        ),
      ),
    );
  }
}

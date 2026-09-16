import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';

class HabitProgressRow extends StatelessWidget {
  const HabitProgressRow({
    super.key,
    required this.item,
    this.onToggle,
    this.onOpen,
  });

  final HabitRowItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onOpen;

  void _toggle() {
    HapticManager.light();
    onToggle?.call();
  }

  void _open() {
    HapticManager.light();
    onOpen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentColor = item.isCompleted
        ? colors.textQuiet
        : colors.textPrimary;

    return GestureDetector(
      onTap: onToggle == null ? null : _toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            item.isCompleted
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: AppSizes.s24,
            color: item.isCompleted ? colors.primaryAlt : colors.textPrimary,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLargeMedium.copyWith(
                          color: contentColor,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: contentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      item.progressLabel,
                      style: AppTypography.bodySmallMediumTight.copyWith(
                        color: contentColor,
                      ),
                    ),
                    if (onOpen != null) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: _open,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.s20,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  progress: item.progress,
                  height: AppSizes.s8,
                  color: colors.primaryAlt,
                  trackColor: colors.borderSubtle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

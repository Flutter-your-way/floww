import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class GettingStartedCard extends StatelessWidget {
  const GettingStartedCard({
    super.key,
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.items,
    this.onToggle,
    this.onDismiss,
  });

  final String title;
  final String progressLabel;
  final double progress;
  final List<ProgressChecklistItem> items;
  final ValueChanged<ProgressChecklistItem>? onToggle;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: AppSizes.s20,
                color: colors.primary,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLargeSemiBold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      progressLabel,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              CircularHeaderButton(
                icon: Icons.close_rounded,
                size: AppSizes.s32,
                iconSize: AppSizes.s16,
                backgroundColor: colors.backgroundSurface,
                onPressed: onDismiss,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppProgressBar(
            progress: progress,
            height: AppSizes.s6,
            color: colors.primaryAlt,
            trackColor: colors.borderSubtle,
          ),
          SizedBox(height: AppSpacing.md),
          for (final item in items)
            _ChecklistRow(
              item: item,
              showDivider: item != items.last,
              onToggle: onToggle == null ? null : () => onToggle!(item),
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.item,
    required this.showDivider,
    this.onToggle,
  });

  static const double _rowHeight = AppSizes.s52;

  final ProgressChecklistItem item;
  final bool showDivider;
  final VoidCallback? onToggle;

  void _toggle() {
    HapticManager.light();
    onToggle?.call();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _rowHeight,
            child: Row(
              children: [
                Icon(
                  item.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: AppSizes.s24,
                  color: item.isCompleted
                      ? colors.primaryAlt
                      : colors.textPrimary,
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.labelMediumSemiBold.copyWith(
                      color: contentColor,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: AppSizes.hairline,
              thickness: AppSizes.hairline,
              color: colors.borderSubtle,
            ),
        ],
      ),
    );
  }
}

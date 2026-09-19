import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';

class WeightHistoryRow extends StatelessWidget {
  const WeightHistoryRow({
    super.key,
    required this.item,
    required this.isBusy,
    this.onRemove,
  });

  final WeightHistoryItem item;
  final bool isBusy;
  final VoidCallback? onRemove;

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
        side: BorderSide(
          color: item.isLatest ? colors.borderGlow : colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.valueLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold.copyWith(
                    color: item.isLatest
                        ? colors.primaryAlt
                        : colors.textPrimary,
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
          _RemoveButton(isBusy: isBusy, onRemove: onRemove),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.isBusy, this.onRemove});

  static const double _loaderStroke = 2;

  final bool isBusy;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isBusy) {
      return SizedBox.square(
        dimension: AppSizes.s32,
        child: Center(
          child: SizedBox.square(
            dimension: AppSizes.s16,
            child: CircularProgressIndicator(
              strokeWidth: _loaderStroke,
              color: colors.destructiveBorder,
            ),
          ),
        ),
      );
    }

    return PressScale(
      onTap: onRemove,
      child: Container(
        width: AppSizes.s32,
        height: AppSizes.s32,
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: colors.destructiveTint,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: colors.destructiveBorder, width: AppSizes.s1),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: AppSizes.s16,
          color: colors.destructiveBorder,
        ),
      ),
    );
  }
}

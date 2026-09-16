import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_add_button.dart';

class WaveSuggestionCard extends StatelessWidget {
  const WaveSuggestionCard({
    super.key,
    required this.label,
    required this.title,
    required this.actionLabel,
    required this.items,
    this.onTryAnother,
    this.onAdd,
  });

  final String label;
  final String title;
  final String actionLabel;
  final List<HabitSuggestionItem> items;
  final VoidCallback? onTryAnother;
  final void Function(HabitSuggestionItem item)? onAdd;

  void _tryAnother() {
    HapticManager.selection();
    onTryAnother?.call();
  }

  @override
  Widget build(BuildContext context) {
    final onAdd = this.onAdd;

    return AppCard(
      variant: AppCardVariant.subtle,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppImages.waveIcon,
                width: AppSizes.s36,
                height: AppSizes.s36,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelMediumSemiBold.copyWith(
                        color: context.colors.primaryAlt,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLargeSemiBold,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              PillButton(
                onPressed: onTryAnother == null ? null : _tryAnother,
                height: AppSizes.s36,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                label: actionLabel,
                labelStyle: AppTypography.labelMediumSemiBold,
              ),
            ],
          ),
          for (final item in items) ...[
            SizedBox(height: AppSpacing.lg),
            _WaveSuggestionRow(
              item: item,
              onAdd: onAdd == null ? null : () => onAdd(item),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaveSuggestionRow extends StatelessWidget {
  const _WaveSuggestionRow({required this.item, this.onAdd});

  final HabitSuggestionItem item;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.subtle,
      radius: AppRadius.md,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLargeSemiBold,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  item.targetLabel,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallMediumTight.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          HabitAddButton(onPressed: onAdd),
        ],
      ),
    );
  }
}

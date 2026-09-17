import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';
import 'package:floww/core/wave/widgets/wave_emoji_tile.dart';

class WavePlanCard extends StatelessWidget {
  const WavePlanCard({
    super.key,
    required this.title,
    required this.items,
    required this.onAction,
  });

  final String title;
  final List<WavePlanItem> items;
  final ValueChanged<WavePlanItem> onAction;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      sections: [
        WaveCardSection(
          child: Text(title, style: AppTypography.bodyLargeBold),
        ),
        for (final item in items)
          _PlanRow(item: item, onAction: () => onAction(item)),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.item, required this.onAction});

  final WavePlanItem item;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return WaveCardSection(
      child: Row(
        children: [
          WaveEmojiTile(
            emoji: item.emoji,
            size: AppSizes.s40,
            backgroundColor: context.colors.bgTinted,
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                WaveSectionLabel(label: item.label),
                SizedBox(height: AppSpacing.xs),
                Text(item.title, style: AppTypography.bodyMediumBold),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  item.detail,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textDim,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          PillButton(
            variant: PillButtonVariant.neutral,
            label: item.actionLabel,
            height: AppSizes.s36,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            labelStyle: AppTypography.bodySmallSemiBold,
            labelColor: context.colors.primary,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

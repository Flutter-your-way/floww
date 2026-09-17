import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveCheckInCard extends StatelessWidget {
  const WaveCheckInCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final WaveFeeling? selected;
  final ValueChanged<WaveFeeling> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;

    return WaveCard(
      sections: [
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.bodyMediumBold),
              SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  for (final feeling in WaveFeeling.values) ...[
                    if (feeling != WaveFeeling.values.first)
                      SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _FeelingOption(
                        feeling: feeling,
                        isSelected: feeling == selected,
                        onTap: () => onSelected(feeling),
                      ),
                    ),
                  ],
                ],
              ),
              if (selected != null) ...[
                SizedBox(height: AppSpacing.lg),
                Text(
                  selected.response,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeelingOption extends StatelessWidget {
  const _FeelingOption({
    required this.feeling,
    required this.isSelected,
    required this.onTap,
  });

  final WaveFeeling feeling;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.press,
        curve: AppMotion.expandCurve,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(feeling.emoji, style: AppTypography.bodyLargeMedium),
            SizedBox(height: AppSpacing.sm),
            Text(
              feeling.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? colors.primary : colors.textSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

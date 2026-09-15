import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

enum _TipLayout { glow, inline, stacked, note }

class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.lightbulb,
  }) : _layout = _TipLayout.glow;

  const TipCard.inline({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb,
  }) : _layout = _TipLayout.inline;

  const TipCard.stacked({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb,
  }) : _layout = _TipLayout.stacked;

  const TipCard.note({
    super.key,
    required this.title,
    this.icon = Icons.graphic_eq_rounded,
  }) : message = null,
       _layout = _TipLayout.note;

  final String title;
  final String? message;
  final IconData icon;
  final _TipLayout _layout;

  @override
  Widget build(BuildContext context) {
    if (_layout == _TipLayout.stacked) {
      return AppCard(
        variant: AppCardVariant.tinted,
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSizes.s16, color: context.colors.primary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_layout == _TipLayout.note) {
      return AppCard(
        variant: AppCardVariant.innerGlow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppSizes.s40,
              height: AppSizes.s40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: context.gradients.primary,
                border: Border.all(
                  color: context.colors.surfaceTranslucent,
                  width: AppSizes.hairline,
                ),
              ),
              child: Icon(
                icon,
                color: context.colors.backgroundSecondary,
                size: AppSizes.s20,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodySmallRegularTight.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_layout == _TipLayout.inline) {
      return AppCard(
        variant: AppCardVariant.tinted,
        radius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Icon(
                icon,
                size: AppSizes.s16,
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '$title: ',
                      style: AppTypography.bodySmallSemiBold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    TextSpan(text: message),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      variant: AppCardVariant.innerGlow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.s32,
            height: AppSizes.s32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: context.gradients.primary,
              border: Border.all(
                color: context.colors.surfaceTranslucent,
                width: AppSizes.hairline,
              ),
            ),
            child: Icon(
              icon,
              color: context.colors.backgroundSecondary,
              size: AppSizes.s20,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmallMediumTight.copyWith(
                    color: context.colors.primaryAlt,
                  ),
                ),
                if (message != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

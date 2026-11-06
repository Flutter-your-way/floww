import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/images/wave_avatar_badge.dart';

enum _TipLayout { glow, inline, stacked, note }

class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.lightbulb,
  }) : _layout = _TipLayout.glow;

  const TipCard.wave({super.key, required this.title, this.message})
    : icon = null,
      _layout = _TipLayout.glow;

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

  const TipCard.note({super.key, required this.title, this.icon})
    : message = null,
      _layout = _TipLayout.note;

  final String title;
  final String? message;
  final IconData? icon;
  final _TipLayout _layout;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
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
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.primary,
                    ),
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
          crossAxisAlignment: icon == null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            icon == null
                ? const WaveAvatarBadge(size: AppSizes.s40, contained: true)
                : _TipIconBadge(icon: icon, size: AppSizes.s40),
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
        crossAxisAlignment: icon == null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          icon == null
              ? const WaveAvatarBadge(size: AppSizes.s36, contained: true)
              : _TipIconBadge(icon: icon, size: AppSizes.s32),
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

class _TipIconBadge extends StatelessWidget {
  const _TipIconBadge({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
    );
  }
}

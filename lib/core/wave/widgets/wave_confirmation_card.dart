import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_card_pop.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';

class WaveConfirmationCard extends StatelessWidget {
  const WaveConfirmationCard({
    super.key,
    required this.title,
    required this.detail,
    this.tone = WaveConfirmationTone.success,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String detail;
  final WaveConfirmationTone tone;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    final colors = context.colors;
    final accent = switch (tone) {
      WaveConfirmationTone.success => colors.success,
      WaveConfirmationTone.water => colors.hydrationAccent,
      WaveConfirmationTone.memory => colors.primary,
      WaveConfirmationTone.warning => colors.warning,
      WaveConfirmationTone.premium => colors.accentViolet,
    };

    return AppCardPop(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: AppShapes.decoration(
          color: Color.alphaBlend(
            accent.withValues(alpha: AppOpacity.tintFill),
            colors.backgroundSecondary,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: accent.withValues(alpha: AppOpacity.innerGlow),
            width: AppSizes.s1,
          ),
        ),
        child: Row(
          children: [
            _WaveConfirmationBadge(tone: tone, accent: accent),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMediumBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    detail,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(width: AppSpacing.md),
              PillButton(
                variant: PillButtonVariant.glass,
                label: actionLabel,
                icon: actionIcon,
                iconColor: accent,
                height: AppSizes.s32,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                labelStyle: AppTypography.bodySmallSemiBold,
                labelColor: colors.textPrimary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveConfirmationBadge extends StatelessWidget {
  const _WaveConfirmationBadge({required this.tone, required this.accent});

  final WaveConfirmationTone tone;
  final Color accent;

  static const double _size = AppSizes.s32;
  static const double _iconSize = AppSizes.s18;

  @override
  Widget build(BuildContext context) {
    final foreground = context.colors.backgroundPrimary;

    return Container(
      height: _size,
      width: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: AppOpacity.buttonGlowStrong),
            blurRadius: AppSizes.s12,
            spreadRadius: -AppSizes.s2,
          ),
        ],
      ),
      child: switch (tone) {
        WaveConfirmationTone.water => SvgPicture.asset(
          AppImages.waterGlassIcon,
          width: _iconSize,
          height: _iconSize,
          theme: SvgTheme(currentColor: foreground),
        ),
        WaveConfirmationTone.success => Icon(
          Icons.check_rounded,
          color: foreground,
          size: _iconSize,
        ),
        WaveConfirmationTone.memory => Icon(
          Icons.psychology_rounded,
          color: foreground,
          size: _iconSize,
        ),
        WaveConfirmationTone.warning => Icon(
          Icons.priority_high_rounded,
          color: foreground,
          size: _iconSize,
        ),
        WaveConfirmationTone.premium => Icon(
          Icons.auto_awesome_rounded,
          color: foreground,
          size: _iconSize,
        ),
      },
    );
  }
}

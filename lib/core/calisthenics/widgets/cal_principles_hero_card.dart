import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/chips/app_status_chip.dart';
import 'package:floww/config/widgets/painters/medal_painter.dart';

class CalPrinciplesHeroCard extends StatelessWidget {
  const CalPrinciplesHeroCard({
    super.key,
    required this.title,
    required this.summary,
    required this.showBadge,
    required this.onOpen,
  });

  static const String _badgeLabel = 'Read once';

  final String title;
  final String summary;
  final bool showBadge;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onOpen,
      child: AppCard(
        variant: AppCardVariant.glow,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            const _PrinciplesEmblem(),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.heading4SemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppMotion.expand,
              child: showBadge
                  ? const AppStatusChip(
                      key: ValueKey(_badgeLabel),
                      label: _badgeLabel,
                      icon: Icons.auto_stories_outlined,
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.s24,
                      color: colors.textSecondary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrinciplesEmblem extends StatelessWidget {
  const _PrinciplesEmblem();

  static const double _size = AppSizes.s56;
  static const double _iconSize = AppSizes.s24;
  static const double _faceScale = 0.78;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: _size,
      child: CustomPaint(
        painter: MedalPainter(
          shape: MedalShape.shield,
          rimGradient: context.gradients.badgeEmber,
          face: colors.backgroundSecondary,
          faceScale: _faceScale,
          glow: colors.primary,
        ),
        child: Center(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: context.gradients.badgeEmber.createShader,
            child: const Icon(Icons.check_rounded, size: _iconSize),
          ),
        ),
      ),
    );
  }
}

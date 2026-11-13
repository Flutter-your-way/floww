import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/achievements/models/badge_rarity.dart';
import 'package:floww/config/widgets/painters/medal_painter.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.rarity,
    required this.isEarned,
    this.icon,
    this.label,
    this.size = AppSizes.s52,
  });

  final BadgeRarity rarity;
  final bool isEarned;
  final IconData? icon;
  final String? label;
  final double size;

  static const double _stackedMinSize = AppSizes.s48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;
    final metal = isEarned ? _metalOf(gradients) : null;
    final label = this.label;
    final showIcon = label == null || size >= _stackedMinSize;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: MedalPainter(
          shape: _shapeOf(rarity),
          rimGradient: metal ?? gradients.badgeLocked,
          face: isEarned
              ? colors.backgroundSecondary
              : colors.backgroundPrimary,
          highlight: colors.textPrimary,
          glow: metal?.colors[1],
        ),
        child: Center(
          child: _BadgeGlyph(
            size: size,
            metal: metal,
            lift: rarity == BadgeRarity.gold,
            icon: showIcon ? icon : null,
            label: label,
          ),
        ),
      ),
    );
  }

  MedalShape _shapeOf(BadgeRarity rarity) => switch (rarity) {
    BadgeRarity.bronze => MedalShape.circle,
    BadgeRarity.silver => MedalShape.hexagon,
    BadgeRarity.gold => MedalShape.shield,
    BadgeRarity.ember => MedalShape.rosette,
    BadgeRarity.prism => MedalShape.star,
  };

  Gradient _metalOf(AppGradientTokens gradients) => switch (rarity) {
    BadgeRarity.bronze => gradients.badgeBronze,
    BadgeRarity.silver => gradients.badgeSilver,
    BadgeRarity.gold => gradients.badgeGold,
    BadgeRarity.ember => gradients.badgeEmber,
    BadgeRarity.prism => gradients.badgePrism,
  };
}

class _BadgeGlyph extends StatelessWidget {
  const _BadgeGlyph({
    required this.size,
    required this.metal,
    required this.lift,
    this.icon,
    this.label,
  });

  final double size;
  final Gradient? metal;
  final bool lift;
  final IconData? icon;
  final String? label;

  static const double _soloIconRatio = 0.38;
  static const double _stackedIconRatio = 0.3;
  static const double _stackedLabelRatio = 0.22;
  static const double _soloLabelRatio = 0.3;
  static const double _shieldLift = 0.04;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metal = this.metal;
    final icon = this.icon;
    final label = this.label;
    final ink = metal == null ? colors.textFaint : colors.textPrimary;
    final isStacked = icon != null && label != null;

    final glyph = Padding(
      padding: EdgeInsets.only(bottom: lift ? size * _shieldLift : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: size * (isStacked ? _stackedIconRatio : _soloIconRatio),
              color: ink,
            ),
          if (label != null)
            Text(
              label,
              style: AppTypography.bodySmallExtraBold.copyWith(
                fontSize:
                    size * (isStacked ? _stackedLabelRatio : _soloLabelRatio),
                height: 1,
                color: ink,
              ),
            ),
        ],
      ),
    );

    if (metal == null) return glyph;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: metal.createShader,
      child: glyph,
    );
  }
}

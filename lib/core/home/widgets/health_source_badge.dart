import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_glass.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/effects/liquid_glass.dart';

class HealthSourceBadge extends StatelessWidget {
  const HealthSourceBadge({
    super.key,
    required this.iconAsset,
    required this.connected,
    required this.semanticLabel,
    this.onTap,
  });

  final String iconAsset;
  final bool connected;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressScale(
        onTap: onTap,
        child: SizedBox.square(
          dimension: AppSizes.s40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              LiquidGlass(
                borderRadius: BorderRadius.circular(AppRadius.full),
                blurSigma: AppGlass.blurSigmaLight,
                refraction: AppGlass.refractionSoft,
                thickness: AppGlass.edgeThicknessTight,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: SvgPicture.asset(
                      iconAsset,
                      height: AppSizes.s20,
                      width: AppSizes.s20,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _StatusDot(
                  color: connected ? colors.success : colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s10,
      height: AppSizes.s10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.backgroundPrimary,
          width: AppSizes.s2,
        ),
      ),
    );
  }
}

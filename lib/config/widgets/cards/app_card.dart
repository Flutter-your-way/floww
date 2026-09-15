import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/effects/inner_glow.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

enum AppCardVariant {
  plain,
  sunken,
  highlighted,
  tinted,
  glow,
  subtle,
  accentOutline,
  innerGlow,
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.plain,
    this.padding,
    this.radius = AppRadius.xl,
    this.borderColor,
    this.glowOpacity = AppOpacity.innerGlow,
    this.glowBlur = AppSizes.s8,
    this.transitionDuration = Duration.zero,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? borderColor;
  final double glowOpacity;
  final double glowBlur;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Gradient? gradient;
    final Color variantBorderColor;
    switch (variant) {
      case AppCardVariant.highlighted:
        backgroundColor = context.colors.bgTinted;
        variantBorderColor = context.colors.borderGlow;
      case AppCardVariant.tinted:
        backgroundColor = context.colors.tint;
        variantBorderColor = context.colors.borderGlow;
      case AppCardVariant.glow:
        gradient = context.gradients.glowCard;
        variantBorderColor = context.colors.borderSubtle;
      case AppCardVariant.accentOutline:
        backgroundColor = context.colors.backgroundSecondary;
        variantBorderColor = context.colors.borderGlow;
      case AppCardVariant.subtle:
        backgroundColor = context.colors.backgroundSecondary;
        variantBorderColor = context.colors.borderSubtle;
      case AppCardVariant.innerGlow:
        backgroundColor = context.colors.backgroundSecondary;
        variantBorderColor = context.colors.borderSubtle;
      case AppCardVariant.sunken:
        backgroundColor = context.colors.backgroundPrimary;
        variantBorderColor = context.colors.borderGlow;
      case AppCardVariant.plain:
        backgroundColor = context.colors.backgroundSecondary;
        variantBorderColor = Colors.transparent;
    }

    final card = AnimatedContainer(
      duration: transitionDuration,
      curve: AppMotion.expandCurve,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: AppShapes.decoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor ?? variantBorderColor, width: 1),
      ),
      child: child,
    );

    if (variant != AppCardVariant.innerGlow) return card;

    return Stack(
      children: [
        card,
        Positioned.fill(
          child: InnerGlow(
            color: context.colors.primary.withValues(alpha: glowOpacity),
            radius: radius,
            blur: glowBlur,
          ),
        ),
      ],
    );
  }
}

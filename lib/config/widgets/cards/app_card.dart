import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

enum AppCardVariant { plain, highlighted, tinted, glow }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.plain,
    this.padding,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Gradient? gradient;
    final Color borderColor;
    switch (variant) {
      case AppCardVariant.highlighted:
        backgroundColor = context.colors.bgTinted;
        borderColor = context.colors.borderGlow;
      case AppCardVariant.tinted:
        backgroundColor = context.colors.tint;
        borderColor = context.colors.borderGlow;
      case AppCardVariant.glow:
        gradient = context.gradients.glowCard;
        borderColor = context.colors.borderSubtle;
      case AppCardVariant.plain:
        backgroundColor = context.colors.backgroundSurface;
        borderColor = context.colors.borderSubtle;
    }

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: AppShapes.decoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}

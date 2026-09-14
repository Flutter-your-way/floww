import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

enum HomeCardVariant { plain, highlighted, tinted }

class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.child,
    this.variant = HomeCardVariant.plain,
    this.padding,
  });

  final Widget child;
  final HomeCardVariant variant;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color borderColor;
    switch (variant) {
      case HomeCardVariant.highlighted:
        backgroundColor = context.colors.bgTinted;
        borderColor = context.colors.borderGlow;
      case HomeCardVariant.tinted:
        backgroundColor = context.colors.tint;
        borderColor = context.colors.borderGlow;
      case HomeCardVariant.plain:
        backgroundColor = context.colors.backgroundSurface;
        borderColor = context.colors.borderSubtle;
    }

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}

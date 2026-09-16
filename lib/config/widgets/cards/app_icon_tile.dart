import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required IconData this.icon,
    this.size = AppSizes.s44,
    this.iconSize = AppSizes.s20,
    this.radius = AppRadius.md,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  }) : assetPath = null;

  const AppIconTile.asset({
    super.key,
    required String this.assetPath,
    this.size = AppSizes.s44,
    this.iconSize = AppSizes.s20,
    this.radius = AppRadius.md,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  }) : icon = null;

  final IconData? icon;
  final String? assetPath;
  final double size;
  final double iconSize;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final assetPath = this.assetPath;
    final foreground = iconColor ?? colors.textPrimary;

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: backgroundColor ?? colors.backgroundSurface,
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: borderColor ?? colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: assetPath == null
          ? Icon(icon, size: iconSize, color: foreground)
          : SvgPicture.asset(
              assetPath,
              height: iconSize,
              width: iconSize,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
    );
  }
}

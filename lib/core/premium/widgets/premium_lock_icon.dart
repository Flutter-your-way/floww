import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class PremiumLockIcon extends StatelessWidget {
  const PremiumLockIcon({
    super.key,
    this.size = AppSizes.s44,
    this.iconSize = AppSizes.s20,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: colors.bgTinted,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderGlow),
      ),
      child: Icon(Icons.lock_rounded, color: colors.primary, size: iconSize),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';

class WorkoutIconTile extends StatelessWidget {
  const WorkoutIconTile({
    super.key,
    this.icon = Icons.fitness_center,
    this.isHighlighted = false,
    this.backgroundColor,
    this.imageUrl,
  });

  final IconData icon;
  final bool isHighlighted;
  final Color? backgroundColor;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imageUrl = this.imageUrl;

    if (imageUrl != null) {
      return AppPhotoTile(
        url: imageUrl,
        fallbackIcon: icon,
        borderColor: isHighlighted ? colors.borderGlow : null,
      );
    }

    return Container(
      width: AppSizes.s48,
      height: AppSizes.s48,
      decoration: AppShapes.decoration(
        color: isHighlighted
            ? colors.bgTinted
            : backgroundColor ?? colors.backgroundElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: isHighlighted
            ? BorderSide(color: colors.borderGlow, width: AppSizes.s1)
            : BorderSide.none,
      ),
      child: Icon(
        icon,
        color: isHighlighted ? colors.primaryAlt : colors.textMuted,
        size: AppSizes.s24,
      ),
    );
  }
}

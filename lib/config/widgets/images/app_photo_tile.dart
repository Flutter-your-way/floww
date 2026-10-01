import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/remote_image.dart';

class AppPhotoTile extends StatelessWidget {
  const AppPhotoTile({
    super.key,
    required this.url,
    required this.fallbackIcon,
    this.size = AppSizes.s48,
    this.radius = AppRadius.md,
    this.borderColor,
  });

  final String? url;
  final IconData fallbackIcon;
  final double size;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final borderColor = this.borderColor;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: AppShapes.decoration(
        color: context.colors.backgroundElevated,
        borderRadius: borderRadius,
      ),
      foregroundDecoration: borderColor == null
          ? null
          : AppShapes.decoration(
              borderRadius: borderRadius,
              side: BorderSide(color: borderColor, width: AppSizes.s1),
            ),
      child: RemoteImage(
        url: url,
        fallbackIcon: fallbackIcon,
        fallbackIconSize: size / 2,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/app_photo_tile.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';
import 'package:floww/core/nutrition/providers/food_photo_provider.dart';

class FoodPhoto extends StatelessWidget {
  const FoodPhoto({
    super.key,
    required this.name,
    this.size = AppSizes.s40,
    this.radius = AppRadius.md,
    this.onTap,
  });

  final String name;
  final double size;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = context.select<FoodPhotoProvider, String?>(
      (provider) => provider.urlFor(name),
    );
    final isUpdating = context.select<FoodPhotoProvider, bool>(
      (provider) => provider.isUpdating(name),
    );

    final tile = Stack(
      alignment: Alignment.center,
      children: [
        AppPhotoTile(
          url: url,
          fallbackIcon: Icons.restaurant_rounded,
          size: size,
          radius: radius,
        ),
        if (isUpdating)
          SizedBox.square(
            dimension: size / 2,
            child: AppSpinner(color: context.colors.primary),
          ),
      ],
    );

    final onTap = this.onTap;
    if (onTap == null) return tile;
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: tile,
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/remote_image.dart';

class WorkoutHeroPhoto extends StatelessWidget {
  const WorkoutHeroPhoto({
    super.key,
    required this.imageUrl,
    this.height,
    this.fill = false,
  });

  final String? imageUrl;
  final double? height;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final height = this.height;

    return ConstrainedBox(
      constraints: fill
          ? const BoxConstraints.expand()
          : height == null
          ? const BoxConstraints(minHeight: AppSizes.s160)
          : BoxConstraints.tightFor(width: double.infinity, height: height),
      child: Stack(
        fit: fill ? StackFit.expand : StackFit.passthrough,
        children: [
          RemoteImage(
            url: imageUrl,
            fit: height == null && !fill ? BoxFit.fitWidth : BoxFit.cover,
            fallbackIcon: Icons.fitness_center,
            fallbackIconSize: AppSizes.s40,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: AppSizes.s32,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: context.gradients.bottomFade),
            ),
          ),
        ],
      ),
    );
  }
}

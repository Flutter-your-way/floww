import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/images/remote_image.dart';

class WorkoutPhotoCard extends StatelessWidget {
  const WorkoutPhotoCard({
    super.key,
    required this.imageUrl,
    required this.child,
    this.onTap,
    this.radius = AppRadius.xl,
    this.padding = const EdgeInsets.all(AppSpacing.xl2),
    this.alignment = Alignment.bottomCenter,
    this.topTrailing,
  });

  final String? imageUrl;
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Widget? topTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(radius);
    final topTrailing = this.topTrailing;

    return PressScale(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppShapes.decoration(
          color: colors.backgroundElevated,
          borderRadius: borderRadius,
        ),
        foregroundDecoration: AppShapes.decoration(
          borderRadius: borderRadius,
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(
              url: imageUrl,
              fallbackIcon: Icons.fitness_center,
              fallbackIconSize: AppSizes.s40,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.gradients.photoScrim,
              ),
            ),
            Padding(
              padding: padding,
              child: Align(alignment: alignment, child: child),
            ),
            if (topTrailing != null)
              Positioned(
                top: AppSpacing.lg,
                right: AppSpacing.lg,
                child: topTrailing,
              ),
          ],
        ),
      ),
    );
  }
}

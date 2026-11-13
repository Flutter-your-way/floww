import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/widgets/images/exercise_video_surface.dart';

class ExerciseMediaFrame extends StatelessWidget {
  const ExerciseMediaFrame({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    this.video,
    this.isLoading = false,
  });

  static const double _landscapeAspectRatio = 16 / 9;
  static const double _portraitAspectRatio = 3 / 4;

  final String? imageUrl;
  final IconData fallbackIcon;
  final ExerciseVideo? video;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isPortrait = video?.isPortrait ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          end: isPortrait ? _portraitAspectRatio : _landscapeAspectRatio,
        ),
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        builder: (context, aspectRatio, child) =>
            AspectRatio(aspectRatio: aspectRatio, child: child),
        child: ExerciseVideoSurface(
          imageUrl: imageUrl,
          video: video,
          isLoading: isLoading,
          fallbackIcon: fallbackIcon,
          fallbackIconSize: AppSizes.s40,
        ),
      ),
    );
  }
}

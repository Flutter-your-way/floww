import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/config/widgets/placeholders/app_spinner.dart';

class ExerciseVideoSurface extends StatefulWidget {
  const ExerciseVideoSurface({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.fallbackIconSize,
    this.video,
    this.isLoading = false,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final ExerciseVideo? video;
  final bool isLoading;

  @override
  State<ExerciseVideoSurface> createState() => _ExerciseVideoSurfaceState();
}

class _ExerciseVideoSurfaceState extends State<ExerciseVideoSurface> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _load(widget.video);
  }

  @override
  void didUpdateWidget(ExerciseVideoSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video?.videoUrl != widget.video?.videoUrl) {
      _release();
      _load(widget.video);
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  Future<void> _load(ExerciseVideo? video) async {
    if (video == null || video.isExpired) return;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      await controller.setVolume(0);
      await controller.setLooping(true);
      await controller.play();
      if (mounted && _controller == controller) setState(() => _isReady = true);
    } catch (e) {
      debugPrint('ExerciseVideoSurface video failed: $e');
      if (mounted && _controller == controller) {
        setState(() => _hasFailed = true);
      }
    }
  }

  void _release() {
    _controller?.dispose();
    _controller = null;
    _isReady = false;
    _hasFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isBuffering = controller != null && !_isReady && !_hasFailed;
    final showsLoader = widget.isLoading || isBuffering;

    return Stack(
      fit: StackFit.expand,
      children: [
        RemoteImage(
          url: widget.video?.thumbnailUrl ?? widget.imageUrl,
          fallbackIcon: widget.fallbackIcon,
          fallbackIconSize: widget.fallbackIconSize,
        ),
        if (controller != null)
          AnimatedOpacity(
            opacity: _isReady ? 1 : 0,
            duration: AppMotion.expand,
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox.fromSize(
                size: controller.value.size,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: showsLoader ? 1 : 0,
            duration: AppMotion.expand,
            child: ColoredBox(
              color: context.colors.scrim,
              child: Center(
                child: AppSpinner(
                  size: AppSizes.s32,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

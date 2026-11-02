import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/entities/exercise_video_entity.dart';
import 'package:floww/config/widgets/images/remote_image.dart';

class ExerciseMediaFrame extends StatefulWidget {
  const ExerciseMediaFrame({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    this.video,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final ExerciseVideo? video;

  @override
  State<ExerciseMediaFrame> createState() => _ExerciseMediaFrameState();
}

class _ExerciseMediaFrameState extends State<ExerciseMediaFrame> {
  static const double _landscapeAspectRatio = 16 / 9;
  static const double _portraitAspectRatio = 3 / 4;

  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _load(widget.video);
  }

  @override
  void didUpdateWidget(ExerciseMediaFrame oldWidget) {
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
      debugPrint('ExerciseMediaFrame video failed: $e');
    }
  }

  void _release() {
    _controller?.dispose();
    _controller = null;
    _isReady = false;
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final controller = _controller;
    final isPortrait = video != null && video.isPortrait;

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(
              url: video?.thumbnailUrl ?? widget.imageUrl,
              fallbackIcon: widget.fallbackIcon,
              fallbackIconSize: AppSizes.s40,
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
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/services/avatar_cache_service.dart';

class CachedAvatarImage extends StatefulWidget {
  const CachedAvatarImage({
    super.key,
    required this.url,
    required this.placeholder,
    required this.error,
    this.size,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
  });

  final String url;
  final Widget placeholder;
  final Widget error;
  final double? size;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  State<CachedAvatarImage> createState() => _CachedAvatarImageState();
}

class _CachedAvatarImageState extends State<CachedAvatarImage> {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Uint8List? _bytes;
  bool _failed = false;
  int _attempt = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(CachedAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url == widget.url) return;
    _attempt = 0;
    _resolve();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _resolve() {
    _retryTimer?.cancel();
    final url = widget.url;
    final cache = AvatarCacheService.instance;
    _bytes = cache.peek(url);
    _failed = false;
    if (_bytes != null) return;

    cache.load(url).then((bytes) {
      if (!mounted || widget.url != url) return;
      if (bytes == null && _attempt < _maxRetries) {
        _attempt++;
        _retryTimer = Timer(_retryDelay * _attempt, () {
          if (mounted) setState(_resolve);
        });
        return;
      }
      setState(() {
        _bytes = bytes;
        _failed = bytes == null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    final size = widget.size;

    if (_failed) return widget.error;
    if (bytes == null) return widget.placeholder;

    return Image.memory(
      bytes,
      fit: widget.fit,
      width: size,
      height: size,
      cacheWidth: size == null
          ? null
          : (size * MediaQuery.devicePixelRatioOf(context)).round(),
      filterQuality: widget.filterQuality,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) return widget.placeholder;
        return _FadeIn(child: child);
      },
      errorBuilder: (context, error, stackTrace) => widget.error,
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.imageReveal,
      curve: AppMotion.imageRevealCurve,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: child,
    );
  }
}

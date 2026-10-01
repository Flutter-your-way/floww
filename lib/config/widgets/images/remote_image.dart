import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    required this.fallbackIcon,
    required this.fallbackIconSize,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final BoxFit fit;

  static const double _thumbnailExtent = AppSizes.s96;
  static const double _thumbnailHeadroom = 2;

  static ImageProvider providerOf(
    BuildContext context,
    String url, {
    bool isThumbnail = false,
  }) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final extent = isThumbnail
        ? _thumbnailExtent * _thumbnailHeadroom
        : MediaQuery.sizeOf(context).width;
    return ResizeImage(
      CachedNetworkImageProvider(url),
      width: (extent * devicePixelRatio).round(),
      policy: ResizeImagePolicy.fit,
    );
  }

  static Future<void> precache(
    BuildContext context,
    Iterable<String> urls, {
    bool isThumbnail = false,
  }) => Future.wait([
    for (final url in urls.toSet())
      precacheImage(
        providerOf(context, url, isThumbnail: isThumbnail),
        context,
        onError: (error, stackTrace) {},
      ),
  ]);

  @override
  Widget build(BuildContext context) {
    final url = this.url;

    if (url == null) {
      return _Fallback(icon: fallbackIcon, size: fallbackIconSize);
    }

    return LayoutBuilder(
      builder: (context, constraints) => Image(
        image: providerOf(
          context,
          url,
          isThumbnail: constraints.biggest.longestSide <= _thumbnailExtent,
        ),
        fit: fit,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : _Fallback(icon: fallbackIcon, size: fallbackIconSize),
        errorBuilder: (context, error, stackTrace) =>
            _Fallback(icon: fallbackIcon, size: fallbackIconSize),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.backgroundElevated,
      child: Center(
        child: Icon(icon, size: size, color: context.colors.textTertiary),
      ),
    );
  }
}

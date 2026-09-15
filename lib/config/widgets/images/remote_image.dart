import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final url = this.url;

    if (url == null) {
      return _Fallback(icon: fallbackIcon, size: fallbackIconSize);
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : _Fallback(icon: fallbackIcon, size: fallbackIconSize),
      errorBuilder: (context, error, stackTrace) =>
          _Fallback(icon: fallbackIcon, size: fallbackIconSize),
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

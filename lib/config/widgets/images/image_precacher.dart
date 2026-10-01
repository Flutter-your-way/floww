import 'package:flutter/material.dart';

import 'package:floww/config/widgets/images/remote_image.dart';

class ImagePrecacher extends StatefulWidget {
  const ImagePrecacher({
    super.key,
    required this.urls,
    required this.child,
    this.thumbnailsOnly = false,
  });

  final List<String?> urls;
  final Widget child;
  final bool thumbnailsOnly;

  @override
  State<ImagePrecacher> createState() => _ImagePrecacherState();
}

class _ImagePrecacherState extends State<ImagePrecacher> {
  final Set<String> _requested = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precache();
  }

  @override
  void didUpdateWidget(covariant ImagePrecacher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _precache();
  }

  void _precache() {
    final pending = [
      for (final url in widget.urls)
        if (url != null && _requested.add(url)) url,
    ];
    if (pending.isEmpty) return;
    RemoteImage.precache(context, pending, isThumbnail: true);
    if (!widget.thumbnailsOnly) RemoteImage.precache(context, pending);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

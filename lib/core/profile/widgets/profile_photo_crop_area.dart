import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfilePhotoCropArea extends StatelessWidget {
  const ProfilePhotoCropArea({
    super.key,
    required this.boundaryKey,
    required this.bytes,
    required this.transformation,
    required this.stageSize,
    required this.cropRect,
    required this.isReady,
    required this.minScale,
    required this.maxScale,
    this.onInteractionEnd,
    this.onCornerDrag,
    this.onCropDrag,
  });

  static const double _handleSize = AppSizes.s44;

  final GlobalKey boundaryKey;
  final Uint8List bytes;
  final TransformationController transformation;
  final Size stageSize;
  final Rect cropRect;
  final bool isReady;
  final double minScale;
  final double maxScale;
  final VoidCallback? onInteractionEnd;
  final void Function(CropCorner corner, Offset delta)? onCornerDrag;
  final ValueChanged<Offset>? onCropDrag;

  @override
  Widget build(BuildContext context) {
    if (!isReady) return const _CropAreaLoader();

    final onInteractionEnd = this.onInteractionEnd;
    final onCropDrag = this.onCropDrag;

    return SizedBox(
      height: stageSize.height,
      width: stageSize.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: transformation,
              minScale: minScale,
              maxScale: maxScale,
              onInteractionEnd: onInteractionEnd == null
                  ? null
                  : (_) => onInteractionEnd(),
              child: _CropImage(bytes: bytes, size: stageSize),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: context.colors.scrim),
            ),
          ),
          Positioned.fromRect(
            rect: cropRect,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: onCropDrag == null
                  ? null
                  : (details) => onCropDrag(details.delta),
              child: _CropWindow(
                boundaryKey: boundaryKey,
                bytes: bytes,
                transformation: transformation,
                stageSize: stageSize,
                cropRect: cropRect,
              ),
            ),
          ),
          for (final corner in CropCorner.values)
            Positioned(
              left: _originOf(corner).dx - _handleSize / 2,
              top: _originOf(corner).dy - _handleSize / 2,
              child: _CropHandle(
                corner: corner,
                size: _handleSize,
                onDrag: onCornerDrag,
              ),
            ),
        ],
      ),
    );
  }

  Offset _originOf(CropCorner corner) => switch (corner) {
    CropCorner.topLeft => cropRect.topLeft,
    CropCorner.topRight => cropRect.topRight,
    CropCorner.bottomLeft => cropRect.bottomLeft,
    CropCorner.bottomRight => cropRect.bottomRight,
  };
}

class _CropWindow extends StatelessWidget {
  const _CropWindow({
    required this.boundaryKey,
    required this.bytes,
    required this.transformation,
    required this.stageSize,
    required this.cropRect,
  });

  final GlobalKey boundaryKey;
  final Uint8List bytes;
  final TransformationController transformation;
  final Size stageSize;
  final Rect cropRect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          key: boundaryKey,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -cropRect.left,
                  top: -cropRect.top,
                  height: stageSize.height,
                  width: stageSize.width,
                  child: ListenableBuilder(
                    listenable: transformation,
                    builder: (context, child) => Transform(
                      transform: transformation.value,
                      child: child,
                    ),
                    child: _CropImage(bytes: bytes, size: stageSize),
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: AppShapes.decoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: context.colors.borderAccent,
              width: AppSizes.s1,
            ),
          ),
        ),
      ],
    );
  }
}

class _CropHandle extends StatelessWidget {
  const _CropHandle({required this.corner, required this.size, this.onDrag});

  final CropCorner corner;
  final double size;
  final void Function(CropCorner corner, Offset delta)? onDrag;

  @override
  Widget build(BuildContext context) {
    final onDrag = this.onDrag;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: onDrag == null
          ? null
          : (details) => onDrag(corner, details.delta),
      child: CustomPaint(
        size: Size.square(size),
        painter: _CropHandlePainter(
          corner: corner,
          color: context.colors.primary,
        ),
      ),
    );
  }
}

class _CropHandlePainter extends CustomPainter {
  const _CropHandlePainter({required this.corner, required this.color});

  static const double _armLength = AppSizes.s20;
  static const double _armWidth = AppSizes.s4;

  final CropCorner corner;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final elbow = Offset(size.width / 2, size.height / 2);
    final towardsRight =
        corner == CropCorner.topLeft || corner == CropCorner.bottomLeft;
    final towardsBottom =
        corner == CropCorner.topLeft || corner == CropCorner.topRight;
    final horizontal = towardsRight ? _armLength : -_armLength;
    final vertical = towardsBottom ? _armLength : -_armLength;

    final path = Path()
      ..moveTo(elbow.dx + horizontal, elbow.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(elbow.dx, elbow.dy + vertical);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _armWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CropHandlePainter oldDelegate) =>
      oldDelegate.corner != corner || oldDelegate.color != color;
}

class _CropImage extends StatelessWidget {
  const _CropImage({required this.bytes, required this.size});

  final Uint8List bytes;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: BoxFit.fill,
      height: size.height,
      width: size.width,
      filterQuality: FilterQuality.high,
    );
  }
}

class _CropAreaLoader extends StatelessWidget {
  const _CropAreaLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: AppSizes.s24,
        width: AppSizes.s24,
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.s2,
          color: context.colors.primary,
        ),
      ),
    );
  }
}

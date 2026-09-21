import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_storage.dart';
import 'package:floww/config/utils/share/widget_capture.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';

class ProfilePhotoCropViewModel extends ChangeNotifier {
  ProfilePhotoCropViewModel(this.source) {
    _resolve();
  }

  static const double minScale = 1.0;
  static const double maxScale = 5.0;
  static const double minCropSide = AppSizes.s96;

  final Uint8List source;
  final TransformationController transformation = TransformationController();

  double? _aspectRatio;
  Size _stageSize = Size.zero;
  Rect _cropRect = Rect.zero;
  bool _isCropping = false;
  bool _disposed = false;
  String? _errorMessage;

  String get title => 'Adjust Photo';

  String get hint => 'Drag the box to move · Corners to resize';

  String get confirmLabel => 'Use Photo';

  bool get isReady => _aspectRatio != null && !_cropRect.isEmpty;

  bool get isCropping => _isCropping;

  String? get errorMessage => _errorMessage;

  Rect get cropRect => _cropRect;

  bool get canReset =>
      !_isCropping &&
      (transformation.value != Matrix4.identity() ||
          _cropRect != _centeredRect(_stageSize));

  Size stageSizeFor(BoxConstraints constraints) {
    final ratio = _aspectRatio ?? 1;
    final width = math.min(constraints.maxWidth, constraints.maxHeight * ratio);
    return Size(width, width / ratio);
  }

  void prepare(Size stageSize) {
    if (stageSize.isEmpty || stageSize == _stageSize) return;
    _stageSize = stageSize;
    _cropRect = _centeredRect(stageSize);
    _notify();
  }

  void moveCrop(Offset delta) {
    if (_cropRect.isEmpty) return;

    final maxLeft = math.max(0.0, _stageSize.width - _cropRect.width);
    final maxTop = math.max(0.0, _stageSize.height - _cropRect.height);

    _cropRect = Rect.fromLTWH(
      (_cropRect.left + delta.dx).clamp(0.0, maxLeft),
      (_cropRect.top + delta.dy).clamp(0.0, maxTop),
      _cropRect.width,
      _cropRect.height,
    );
    _notify();
  }

  void resizeCrop(CropCorner corner, Offset delta) {
    if (_cropRect.isEmpty) return;

    final anchor = switch (corner) {
      CropCorner.topLeft => _cropRect.bottomRight,
      CropCorner.topRight => _cropRect.bottomLeft,
      CropCorner.bottomLeft => _cropRect.topRight,
      CropCorner.bottomRight => _cropRect.topLeft,
    };
    final dragged =
        switch (corner) {
          CropCorner.topLeft => _cropRect.topLeft,
          CropCorner.topRight => _cropRect.topRight,
          CropCorner.bottomLeft => _cropRect.bottomLeft,
          CropCorner.bottomRight => _cropRect.bottomRight,
        } +
        delta;
    final maxSide = switch (corner) {
      CropCorner.topLeft => math.min(anchor.dx, anchor.dy),
      CropCorner.topRight => math.min(_stageSize.width - anchor.dx, anchor.dy),
      CropCorner.bottomLeft => math.min(
        anchor.dx,
        _stageSize.height - anchor.dy,
      ),
      CropCorner.bottomRight => math.min(
        _stageSize.width - anchor.dx,
        _stageSize.height - anchor.dy,
      ),
    };
    if (maxSide < minCropSide) return;

    final side = math
        .max((dragged.dx - anchor.dx).abs(), (dragged.dy - anchor.dy).abs())
        .clamp(minCropSide, maxSide);

    _cropRect = switch (corner) {
      CropCorner.topLeft => Rect.fromLTWH(
        anchor.dx - side,
        anchor.dy - side,
        side,
        side,
      ),
      CropCorner.topRight => Rect.fromLTWH(
        anchor.dx,
        anchor.dy - side,
        side,
        side,
      ),
      CropCorner.bottomLeft => Rect.fromLTWH(
        anchor.dx - side,
        anchor.dy,
        side,
        side,
      ),
      CropCorner.bottomRight => Rect.fromLTWH(anchor.dx, anchor.dy, side, side),
    };
    _notify();
  }

  void reset() {
    transformation.value = Matrix4.identity();
    _cropRect = _centeredRect(_stageSize);
    _notify();
  }

  void onInteractionEnd() => _notify();

  Future<Uint8List?> crop(GlobalKey boundaryKey) async {
    if (_isCropping || _cropRect.isEmpty) return null;
    _isCropping = true;
    _errorMessage = null;
    _notify();

    try {
      final bytes = await WidgetCapture.toPngBytesOrNull(
        boundaryKey,
        pixelRatio: AppStorage.avatarOutputSize / _cropRect.width,
      );
      if (bytes == null) {
        _errorMessage = 'Could not crop your photo. Please try again.';
      }
      return bytes;
    } finally {
      _isCropping = false;
      _notify();
    }
  }

  static Rect _centeredRect(Size stage) {
    if (stage.isEmpty) return Rect.zero;
    final side = math.min(stage.width, stage.height);
    return Rect.fromLTWH(
      (stage.width - side) / 2,
      (stage.height - side) / 2,
      side,
      side,
    );
  }

  Future<void> _resolve() async {
    try {
      final codec = await ui.instantiateImageCodec(source);
      final frame = await codec.getNextFrame();
      _aspectRatio = frame.image.width / frame.image.height;
      frame.image.dispose();
      codec.dispose();
    } catch (e, stackTrace) {
      debugPrint('resolveCropImage failed: $e\n$stackTrace');
      _aspectRatio = 1;
      _errorMessage = 'Could not read that photo. Please try another one.';
    }
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    transformation.dispose();
    super.dispose();
  }
}

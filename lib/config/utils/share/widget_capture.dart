import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:floww/config/utils/share/share_service.dart';

class WidgetCapture {
  const WidgetCapture._();

  static const double _pixelRatio = 3.0;
  static const Duration _settleDelay = Duration(milliseconds: 40);

  static Future<Uint8List> toPngBytes(GlobalKey boundaryKey) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw const ShareException(
          ShareErrorCode.captureFailed,
          'Could not render your card. Please try again.',
        );
      }
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(_settleDelay);
      }
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final bytes = data?.buffer.asUint8List();
      if (bytes == null) {
        throw const ShareException(
          ShareErrorCode.captureFailed,
          'Could not render your card. Please try again.',
        );
      }
      return bytes;
    } on ShareException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('toPngBytes failed: $e\n$stackTrace');
      throw const ShareException(
        ShareErrorCode.captureFailed,
        'Could not render your card. Please try again.',
      );
    }
  }
}

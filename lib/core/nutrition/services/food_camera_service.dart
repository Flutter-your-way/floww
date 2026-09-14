import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

enum FoodCameraErrorCode { permissionDenied, unavailable, captureFailed }

class FoodCameraException implements Exception {
  FoodCameraException(this.code, this.message);

  final FoodCameraErrorCode code;
  final String message;

  @override
  String toString() => message;
}

class FoodCameraService {
  static const String photoMimeType = 'image/jpeg';
  static const String _accessDeniedCodePrefix = 'CameraAccess';

  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<void> start() async {
    await stop();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw FoodCameraException(
          FoodCameraErrorCode.unavailable,
          'No camera found on this device.',
        );
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();
    } on FoodCameraException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('startCamera failed: $e\n$stackTrace');
      await stop();
      final accessDenied =
          e is CameraException && e.code.startsWith(_accessDeniedCodePrefix);
      throw accessDenied
          ? FoodCameraException(
              FoodCameraErrorCode.permissionDenied,
              'Camera access is off. Allow it in Settings to scan your meals.',
            )
          : FoodCameraException(
              FoodCameraErrorCode.unavailable,
              'Could not start the camera. Please try again.',
            );
    }
  }

  Future<Uint8List> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw FoodCameraException(
        FoodCameraErrorCode.unavailable,
        'The camera is not ready yet.',
      );
    }

    final Uint8List bytes;
    try {
      final photo = await controller.takePicture();
      bytes = await photo.readAsBytes();
    } catch (e, stackTrace) {
      debugPrint('capturePhoto failed: $e\n$stackTrace');
      throw FoodCameraException(
        FoodCameraErrorCode.captureFailed,
        'Could not take the photo. Please try again.',
      );
    }

    try {
      await controller.pausePreview();
    } catch (e) {
      debugPrint('pausePreview failed: $e');
    }
    return bytes;
  }

  Future<void> resumePreview() async {
    final controller = _controller;
    if (controller == null || !controller.value.isPreviewPaused) return;
    try {
      await controller.resumePreview();
    } catch (e) {
      debugPrint('resumePreview failed: $e');
    }
  }

  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

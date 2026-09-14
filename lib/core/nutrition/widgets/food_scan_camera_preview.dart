import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FoodScanCameraPreview extends StatelessWidget {
  const FoodScanCameraPreview({super.key, this.controller, this.photo});

  final CameraController? controller;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    if (photo != null) {
      return SizedBox.expand(
        child: Image.memory(photo, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    final controller = this.controller;
    final previewSize = controller?.value.previewSize;
    if (controller == null ||
        !controller.value.isInitialized ||
        previewSize == null) {
      return const SizedBox.expand();
    }

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

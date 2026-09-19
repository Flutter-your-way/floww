import 'dart:ui' as ui;

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/constants/app_orb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OrbShader {
  OrbShader._();

  static ui.FragmentProgram? _program;
  static ui.Image? _texture;

  static bool get isAvailable => _program != null && _texture != null;

  static ui.Image? get texture => _texture;

  static Future<void> preload() async {
    await Future.wait([_loadProgram(), _loadTexture()]);
  }

  static Future<void> _loadProgram() async {
    if (_program != null) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(AppOrb.shaderAsset);
    } catch (error) {
      debugPrint('OrbShader program unavailable: $error');
    }
  }

  static Future<void> _loadTexture() async {
    if (_texture != null) return;
    try {
      final data = await rootBundle.load(AppImages.restoreOrb);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _texture = frame.image;
      codec.dispose();
    } catch (error) {
      debugPrint('OrbShader texture unavailable: $error');
    }
  }

  static ui.FragmentShader? create() => _program?.fragmentShader();
}

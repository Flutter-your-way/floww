import 'dart:ui' as ui;

import 'package:floww/config/constants/app_orb.dart';
import 'package:flutter/foundation.dart';

class OrbShader {
  OrbShader._();

  static ui.FragmentProgram? _program;

  static bool get isAvailable => _program != null;

  static Future<void> preload() async {
    if (_program != null) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(AppOrb.shaderAsset);
    } catch (error) {
      debugPrint('OrbShader program unavailable: $error');
    }
  }

  static ui.FragmentShader? create() => _program?.fragmentShader();
}

import 'dart:ui' as ui;

import 'package:floww/config/constants/app_glass.dart';
import 'package:flutter/foundation.dart';

class LiquidGlassShader {
  LiquidGlassShader._();

  static ui.FragmentProgram? _program;

  static bool get isAvailable =>
      _program != null && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> preload() async {
    if (_program != null || !ui.ImageFilter.isShaderFilterSupported) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(AppGlass.shaderAsset);
    } catch (error) {
      debugPrint('LiquidGlassShader unavailable: $error');
    }
  }

  static ui.FragmentShader? create() => _program?.fragmentShader();
}

import 'dart:ui' as ui;

import 'package:floww/config/constants/app_glass.dart';
import 'package:flutter/foundation.dart';

class GlassLensShader {
  GlassLensShader._();

  static ui.FragmentProgram? _program;

  static bool get isAvailable =>
      _program != null && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> preload() async {
    if (_program != null || !ui.ImageFilter.isShaderFilterSupported) return;
    try {
      _program = await ui.FragmentProgram.fromAsset(AppGlass.lensShaderAsset);
    } catch (error) {
      debugPrint('GlassLensShader unavailable: $error');
    }
  }

  static ui.ImageFilter? filter({
    required ui.Rect rectPx,
    required double radiusPx,
    required double strength,
  }) {
    final program = _program;
    if (!isAvailable || program == null) return null;
    final shader = program.fragmentShader()
      ..setFloat(2, rectPx.left)
      ..setFloat(3, rectPx.top)
      ..setFloat(4, rectPx.width)
      ..setFloat(5, rectPx.height)
      ..setFloat(6, radiusPx)
      ..setFloat(7, strength)
      ..setFloat(8, 1);
    return ui.ImageFilter.shader(shader);
  }
}

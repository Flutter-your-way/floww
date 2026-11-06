import 'dart:ui' as ui;

import 'package:floww/config/constants/app_glass.dart';
import 'package:flutter/foundation.dart';

class LiquidGlassLensShader {
  LiquidGlassLensShader._();

  static ui.FragmentProgram? _lens;
  static ui.FragmentProgram? _backdrop;
  static Future<void>? _loading;
  static final ValueNotifier<int> loaded = ValueNotifier<int>(0);

  static ui.FragmentProgram? get lens => _lens;

  static ui.FragmentProgram? get backdrop => _backdrop;

  static bool get backdropActive {
    if (_backdrop == null) return false;
    try {
      return ui.ImageFilter.isShaderFilterSupported;
    } catch (_) {
      return false;
    }
  }

  static Future<void> preload() => _loading ??= _load();

  static Future<void> _load() async {
    _lens = await _tryLoad(AppGlass.tabLensShaderAsset);
    _backdrop = await _tryLoad(AppGlass.tabBackdropShaderAsset);
    loaded.value++;
  }

  static Future<ui.FragmentProgram?> _tryLoad(String asset) async {
    try {
      return await ui.FragmentProgram.fromAsset(asset);
    } catch (error) {
      debugPrint('LiquidGlassLensShader unavailable ($asset): $error');
      return null;
    }
  }
}

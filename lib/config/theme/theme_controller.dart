import 'package:floww/config/theme/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController(this._mode);

  AppThemeMode _mode;
  AppThemeMode get mode => _mode;

  Future<void> setMode(AppThemeMode newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_mode', newMode.name);
  }
}

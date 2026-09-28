import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardStyleController extends ChangeNotifier {
  CardStyleController(this._isGlass);

  static const String storageKey = 'app_glass_cards';
  static const bool defaultIsGlass = true;

  bool _isGlass;
  bool get isGlass => _isGlass;

  static bool load(SharedPreferences prefs) =>
      prefs.getBool(storageKey) ?? defaultIsGlass;

  Future<void> setGlass(bool value) async {
    if (_isGlass == value) return;
    _isGlass = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKey, value);
  }
}

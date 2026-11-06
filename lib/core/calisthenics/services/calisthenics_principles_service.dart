import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalisthenicsPrinciplesService {
  static const String _readKey = 'cal_principles_read';

  Future<bool> hasRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_readKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_readKey, true);
    } catch (error) {
      debugPrint('markPrinciplesRead failed: $error');
    }
  }
}

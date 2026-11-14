import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutPlanBannerService {
  static const String _dismissedKey = 'workout_plan_banner_dismissed';

  Future<bool> isDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_dismissedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dismissedKey, true);
    } catch (error) {
      debugPrint('markPlanBannerDismissed failed: $error');
    }
  }
}

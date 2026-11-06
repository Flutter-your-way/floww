import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/core/nutrition/models/meal_schedule.dart';

class MealScheduleService {
  MealScheduleService._();

  static final MealScheduleService instance = MealScheduleService._();

  static const String _mealsPerDayKey = 'nutrition_meals_per_day';

  final ValueNotifier<MealSchedule> schedule = ValueNotifier(
    MealSchedule.standard,
  );

  bool _restored = false;

  MealSchedule get current => schedule.value;

  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_mealsPerDayKey);
      if (saved != null) schedule.value = MealSchedule(saved);
    } catch (error) {
      debugPrint('restore meal schedule failed: $error');
    }
  }

  Future<void> setMealsPerDay(int mealsPerDay) async {
    final next = MealSchedule(mealsPerDay);
    if (next.mealsPerDay == current.mealsPerDay) return;
    schedule.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_mealsPerDayKey, next.mealsPerDay);
    } catch (error) {
      debugPrint('save meal schedule failed: $error');
    }
  }
}

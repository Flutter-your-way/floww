import 'package:shared_preferences/shared_preferences.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';

class DietPlanProgress {
  const DietPlanProgress({
    required this.plan,
    required this.completedDays,
    required this.currentDayNumber,
  });

  final DietPlan plan;
  final Set<int> completedDays;
  final int currentDayNumber;

  bool get isFinished => currentDayNumber > DietPlan.lengthDays;

  double get completion => completedDays.length / DietPlan.lengthDays;
}

class DietPlanService {
  DietPlanService(this._logService);

  static const String _startedAtKey = 'diet_plan_started_at';
  static const double _completionThreshold = 0.8;

  final NutritionLogService _logService;

  Future<DietPlanProgress?> loadProgress({
    required int targetCalories,
    bool startIfMissing = false,
  }) async {
    final uid = _logService.userId;
    if (uid == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final key = '${_startedAtKey}_$uid';
    final today = AppDateUtils.dateOnly(DateTime.now());
    var startedAt = DateTime.tryParse(prefs.getString(key) ?? '');
    if (startedAt == null) {
      if (!startIfMissing) return null;
      startedAt = today;
      await prefs.setString(key, today.toIso8601String());
    }

    final plan = DietPlan.generate(
      startDate: startedAt,
      targetCalories: targetCalories,
    );
    final tomorrow = AppDateUtils.addDays(today, 1);
    final until = tomorrow.isBefore(plan.endDate) ? tomorrow : plan.endDate;
    final logs = until.isAfter(plan.startDate)
        ? await _logService.fetchFoodLogs(plan.startDate, until)
        : const <FoodLog>[];

    final caloriesByDay = <int, double>{};
    for (final log in logs) {
      final dayNumber = plan.dayNumberFor(log.loggedAt);
      caloriesByDay[dayNumber] =
          (caloriesByDay[dayNumber] ?? 0) + log.macros.calories;
    }

    final completedDays = {
      for (final day in plan.days)
        if ((caloriesByDay[day.dayNumber] ?? 0) >=
            day.calories * _completionThreshold)
          day.dayNumber,
    };

    return DietPlanProgress(
      plan: plan,
      completedDays: completedDays,
      currentDayNumber: plan.dayNumberFor(today),
    );
  }
}

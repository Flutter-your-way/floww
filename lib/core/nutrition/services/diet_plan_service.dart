import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/settings/services/settings_service.dart';

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
  DietPlanService(this._logService, {SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService();

  static const double _completionThreshold = 0.8;

  final NutritionLogService _logService;
  final SettingsService _settingsService;

  Future<DietPlanProgress?> loadProgress({
    required int targetCalories,
    bool startIfMissing = false,
  }) async {
    final uid = _logService.userId;
    if (uid == null) return null;

    final today = AppDateUtils.dateOnly(DateTime.now());
    var startedAt = await _settingsService.dietPlanStartedAt();
    if (startedAt == null) {
      if (!startIfMissing) return null;
      startedAt = today;
      await _settingsService.setDietPlanStartedAt(today);
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

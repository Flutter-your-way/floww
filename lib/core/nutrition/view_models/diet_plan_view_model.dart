import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class DietPlanViewModel extends ChangeNotifier {
  DietPlanViewModel(this._planService, this._goal) {
    load();
  }

  final DietPlanService _planService;
  final NutritionGoal _goal;
  DietPlanProgress? _progress;
  bool _isLoading = true;
  String? _errorMessage;
  int? _expandedDay;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  bool get hasPlan => _progress != null;

  String get emptyMessage =>
      _errorMessage ?? 'Sign in to get your 30-day WAVE diet plan.';

  DietPlan get _plan => _progress!.plan;

  String get createdLabel =>
      'Created ${AppDateUtils.monthDayYear(_plan.startDate)} · '
      '${NumberFormatter.grouped(_plan.targetCalories)} kcal/day target';

  String get progressLabel =>
      '${_progress!.completedDays.length} / ${DietPlan.lengthDays} days completed';

  String get percentLabel => NutritionLabels.percent(_progress!.completion);

  double get progress => _progress!.completion;

  String get startLabel => 'Day 1';

  String get endLabel => 'Day ${DietPlan.lengthDays}';

  List<DietPlanDayItem> get days => [
    for (final day in _plan.days)
      DietPlanDayItem(
        dayNumber: day.dayNumber,
        caloriesLabel: '${NumberFormatter.grouped(day.calories)} kcal total',
        isCompleted: _progress!.completedDays.contains(day.dayNumber),
        isToday: day.dayNumber == _progress!.currentDayNumber,
        isExpanded: day.dayNumber == _expandedDay,
        proteinLabel: '${day.proteinG}g',
        carbsLabel: '${day.carbsG}g',
        fatLabel: '${day.fatG}g',
        meals: [
          for (final meal in day.meals)
            DietPlanMealItem(
              meal: meal.mealType,
              name: meal.name,
              macrosLabel:
                  'P ${meal.proteinG}g   C ${meal.carbsG}g   F ${meal.fatG}g',
              caloriesLabel: '${meal.calories} kcal',
            ),
        ],
      ),
  ];

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _progress = await _planService.loadProgress(
        targetCalories: _goal.calories,
        startIfMissing: true,
      );
      final progress = _progress;
      if (progress != null && !progress.isFinished) {
        _expandedDay ??= progress.currentDayNumber;
      }
    } catch (e) {
      debugPrint('load diet plan failed: $e');
      _errorMessage = 'Could not load your diet plan. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDay(int dayNumber) {
    _expandedDay = _expandedDay == dayNumber ? null : dayNumber;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class MealDetailsViewModel extends ChangeNotifier {
  MealDetailsViewModel(
    this._logService,
    this._date,
    this._meal,
    this._goalService,
  ) : _day = NutritionDay(date: _date, goal: NutritionGoal.defaults) {
    _goalSubscription = _goalService.watch().listen(
      (goal) {
        _goal = goal;
        _day = _day.copyWithGoal(goal);
        notifyListeners();
      },
      onError: (Object error) => debugPrint('meal goal failed: $error'),
    );
    _subscription = _logService
        .watchLogs(_date, AppDateUtils.addDays(_date, 1))
        .listen(
          (logs) {
            _day = NutritionDay(
              date: _date,
              goal: _goal,
              foodLogs: logs.foods,
              waterLogs: logs.waters,
            );
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('meal details watch failed: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  static const double _lowProteinShare = 0.15;
  static const double _highFatShare = 0.4;
  static const double _highCarbShare = 0.6;

  final NutritionLogService _logService;
  final DateTime _date;
  final NutritionGoalService _goalService;
  NutritionGoal _goal = NutritionGoal.defaults;
  MealType _meal;
  NutritionDay _day;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<NutritionLogs>? _subscription;
  StreamSubscription<NutritionGoal>? _goalSubscription;
  bool _disposed = false;

  DateTime get date => _date;

  MealType get meal => _meal;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get canEdit =>
      !_date.isBefore(AppDateUtils.dateOnly(DateTime.now()));

  List<FoodLog> get _logs => _day.logsFor(_meal);

  bool get isEmpty => _logs.isEmpty;

  MacroSplit get _split => MacroSplit(
    proteinG: _sum((log) => log.macros.proteinG),
    carbsG: _sum((log) => log.macros.carbsG),
    fatG: _sum((log) => log.macros.fatG),
  );

  double _sum(double Function(FoodLog log) pick) =>
      _logs.fold(0, (total, log) => total + pick(log));

  String get timeLabel {
    final day = AppDateUtils.relativeDay(_date);
    return _logs.isEmpty
        ? day
        : '$day, ${AppDateUtils.time(_logs.first.loggedAt)}';
  }

  String get caloriesLabel =>
      NutritionLabels.number(_sum((log) => log.macros.calories));

  List<MacroShare> get shares {
    final split = _split;
    return [
      for (final macro in MacroNutrient.values)
        MacroShare(
          macro: macro,
          share: split.shareOf(macro),
          shareLabel: NutritionLabels.percent(split.shareOf(macro)),
          amountLabel: NutritionLabels.grams(split.gramsOf(macro)),
        ),
    ];
  }

  String get itemCountLabel =>
      NutritionLabels.count(_logs.length, 'item', 'items');

  List<FoodItemData> get items => [
    for (final log in _logs)
      FoodItemData(
        id: log.id,
        name: log.food.name,
        servingLabel: log.food.servingDescription,
        caloriesLabel: NutritionLabels.number(log.macros.calories),
        proteinLabel: 'P ${NutritionLabels.grams(log.macros.proteinG)}',
        carbsLabel: 'C ${NutritionLabels.grams(log.macros.carbsG)}',
        fatLabel: 'F ${NutritionLabels.grams(log.macros.fatG)}',
        isScanned: log.food.source == FoodSource.scan,
      ),
  ];

  List<MealTimelineEntry> get timeline => [
    for (final meal in MealType.values)
      MealTimelineEntry(
        meal: meal,
        caloriesLabel: NutritionLabels.number(_day.caloriesFor(meal)),
        isSelected: meal == _meal,
      ),
  ];

  String get insightMessage {
    final name = _meal.label.toLowerCase();
    if (_logs.isEmpty) {
      return 'Nothing logged for $name yet. Add a food to see how balanced '
          'it is.';
    }
    final split = _split;
    if (split.shareOf(MacroNutrient.protein) < _lowProteinShare) {
      return 'Your $name is light on protein. Add a lean source like chicken, '
          'eggs or Greek yogurt to stay full longer.';
    }
    if (split.shareOf(MacroNutrient.fats) > _highFatShare) {
      return 'Your $name is high in fat. Balance your next meal with '
          'vegetables and lean protein.';
    }
    if (split.shareOf(MacroNutrient.carbs) > _highCarbShare) {
      return 'Your $name is carb-heavy. Pair it with protein so the energy '
          'lasts longer.';
    }
    return 'Great balance! Your $name has a good mix of protein, healthy '
        'fats, and complex carbs to keep you fueled.';
  }

  void selectMeal(MealType meal) {
    if (meal == _meal) return;
    _meal = meal;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    if (!canEdit) return;
    _errorMessage = null;
    try {
      await _logService.deleteFoodLog(id);
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }
}

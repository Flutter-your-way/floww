import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class LogFoodViewModel extends ChangeNotifier {
  LogFoodViewModel(this._logService, this._date, this._meal) {
    _subscription = _logService
        .watchLogs(_date, AppDateUtils.addDays(_date, 1))
        .listen(
          (logs) {
            _dayLogs = logs.foods;
            notifyListeners();
          },
          onError: (Object error) => debugPrint('log food watch failed: $error'),
        );
  }

  final NutritionLogService _logService;
  final DateTime _date;
  MealType _meal;
  String _query = '';
  List<FoodLog> _dayLogs = const [];
  final Set<String> _saving = {};
  String? _errorMessage;
  StreamSubscription<NutritionLogs>? _subscription;
  bool _disposed = false;

  MealType get meal => _meal;

  List<MealType> get meals => MealType.values;

  String? get errorMessage => _errorMessage;

  List<CatalogFood> get results => FoodCatalog.search(_query);

  String get emptyMessage => 'No foods match "${_query.trim()}".';

  bool isAdded(CatalogFood food) => _dayLogs.any(
    (log) => log.mealType == _meal && food.matches(log.food),
  );

  bool isSaving(CatalogFood food) => _saving.contains(food.displayName);

  String caloriesLabelOf(CatalogFood food) =>
      NutritionLabels.kcal(food.calories);

  String macrosLabelOf(CatalogFood food) =>
      NutritionLabels.macroLine(food.proteinG, food.carbsG, food.fatG);

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void selectMeal(MealType meal) {
    _meal = meal;
    notifyListeners();
  }

  Future<void> add(CatalogFood food) async {
    if (isAdded(food) || isSaving(food)) return;
    final key = food.displayName;
    _saving.add(key);
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _logService.userId;
      if (userId == null) {
        throw NutritionLogException('Please sign in again.');
      }
      final now = DateTime.now();
      await _logService.addFoodLog(
        FoodLog(
          food: food.toFoodModel(
            id: _logService.newFoodLogId(),
            userId: userId,
            createdAt: now,
          ),
          mealType: _meal,
          loggedAt: AppDateUtils.atTimeOf(_date, now),
        ),
      );
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
    } finally {
      _saving.remove(key);
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
    super.dispose();
  }
}

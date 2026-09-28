import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/food_portion_result.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/custom_food_service.dart';
import 'package:floww/core/nutrition/services/food_scan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class LogFoodViewModel extends ChangeNotifier {
  LogFoodViewModel(
    this._logService,
    this._date,
    this._meal, [
    this._query = '',
    CustomFoodService? customFoodService,
    FoodScanService? foodService,
    NutritionGoalService? goalService,
  ]) : _customFoodService = customFoodService ?? CustomFoodService(),
       _foodService = foodService ?? FoodScanService(),
       _goalService = goalService ?? NutritionGoalService() {
    _scheduleRemoteSearch();
    _customSubscription = _customFoodService.watchFoods().listen(
      (foods) {
        _customFoods = foods;
        notifyListeners();
      },
      onError: (Object error) =>
          debugPrint('custom foods watch failed: $error'),
    );
    _subscription = _logService
        .watchLogs(_date, AppDateUtils.addDays(_date, 1))
        .listen(
          (logs) {
            _dayLogs = logs.foods;
            notifyListeners();
          },
          onError: (Object error) =>
              debugPrint('log food watch failed: $error'),
        );
  }

  static const Duration _searchDebounce = Duration(milliseconds: 450);
  static const int _minRemoteQueryLength = 2;
  static const String _searchFailedMessage = "Couldn't load more foods.";
  static const String _describeFailedMessage =
      'WAVE could not estimate this meal. Please try again.';

  final NutritionLogService _logService;
  final CustomFoodService _customFoodService;
  final FoodScanService _foodService;
  final NutritionGoalService _goalService;
  final DateTime _date;
  MealType _meal;
  String _query;
  List<FoodLog> _dayLogs = const [];
  List<CustomFood> _customFoods = const [];
  StreamSubscription<List<CustomFood>>? _customSubscription;
  final Set<String> _saving = {};
  String? _errorMessage;
  StreamSubscription<NutritionLogs>? _subscription;
  bool _disposed = false;
  Timer? _searchTimer;
  List<CatalogFood> _remoteFoods = const [];
  bool _isSearching = false;
  String? _searchNotice;
  bool _isDescribing = false;

  MealType get meal => _meal;

  DateTime get date => _date;

  bool get showsEmptyMessage => results.isEmpty && !_isSearching;

  String get searchingLabel => 'Searching the USDA food database...';

  List<MealType> get meals => MealType.values;

  String? get errorMessage => _errorMessage;

  List<CustomFood> get customFoods => _customFoods;

  List<CatalogFood> get results {
    final query = _query.trim().toLowerCase();
    final custom = [
      for (final food in _customFoods)
        if (query.isEmpty || food.name.toLowerCase().contains(query))
          food.catalog,
    ];
    final local = [...custom, ...FoodCatalog.search(_query)];
    final seen = {for (final food in local) food.displayName.toLowerCase()};
    return [
      ...local,
      for (final food in _remoteFoods)
        if (seen.add(food.displayName.toLowerCase())) food,
    ];
  }

  String get emptyMessage => 'No foods match "${_query.trim()}".';

  bool get isSearching => _isSearching;

  String? get searchNotice => _searchNotice;

  bool get isDescribing => _isDescribing;

  bool get canDescribe =>
      _query.trim().length >= _minRemoteQueryLength && !_isDescribing;

  String get describeLabel => 'Estimate "${_query.trim()}" with WAVE';

  FoodLog? loggedEntryOf(CatalogFood food) {
    for (final log in _dayLogs.reversed) {
      if (log.mealType == _meal && food.matches(log.food)) return log;
    }
    return null;
  }

  bool isAdded(CatalogFood food) => loggedEntryOf(food) != null;

  bool isSaving(CatalogFood food) => _saving.contains(food.displayName);

  String caloriesLabelOf(CatalogFood food) => NutritionLabels.kcal(
    loggedEntryOf(food)?.macros.calories ?? food.calories,
  );

  String macrosLabelOf(CatalogFood food) {
    final logged = loggedEntryOf(food);
    if (logged == null) {
      return NutritionLabels.macroLine(food.proteinG, food.carbsG, food.fatG);
    }
    final macros = logged.macros;
    return 'Logged ${logged.food.servingDescription} · '
        '${NutritionLabels.macroLine(macros.proteinG, macros.carbsG, macros.fatG)}';
  }

  void search(String query) {
    _query = query;
    _scheduleRemoteSearch();
    notifyListeners();
  }

  void _scheduleRemoteSearch() {
    _searchTimer?.cancel();
    _remoteFoods = const [];
    _searchNotice = null;
    final query = _query.trim();
    _isSearching = query.length >= _minRemoteQueryLength;
    if (!_isSearching) return;
    _searchTimer = Timer(_searchDebounce, () => _searchRemote(query));
  }

  Future<void> _searchRemote(String query) async {
    try {
      final foods = await _foodService.searchFoods(query);
      if (_query.trim() != query) return;
      _remoteFoods = foods;
    } catch (e) {
      if (_query.trim() != query) return;
      _searchNotice = e is FoodScanException ? e.message : _searchFailedMessage;
    }
    _isSearching = false;
    notifyListeners();
  }

  Future<({FoodModel food, NutritionGoal goal})?> describe() async {
    if (!canDescribe) return null;
    _isDescribing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final goal = _goalService.load();
      final food = await _foodService.describeFood(_query);
      return (food: food, goal: await goal);
    } catch (e) {
      _errorMessage = e is FoodScanException
          ? e.message
          : _describeFailedMessage;
      return null;
    } finally {
      _isDescribing = false;
      notifyListeners();
    }
  }

  void selectMeal(MealType meal) {
    _meal = meal;
    notifyListeners();
  }

  Future<void> applyPortion(CatalogFood food, FoodPortionResult result) {
    final portion = result.portion;
    return portion == null ? remove(food) : savePortion(food, portion);
  }

  Future<void> savePortion(CatalogFood food, CatalogFood portion) async {
    if (isSaving(food)) return;
    final logged = loggedEntryOf(food);

    return _save(food, () async {
      final userId = _logService.userId;
      if (userId == null) {
        throw NutritionLogException('Please sign in again.');
      }
      final now = DateTime.now();
      await _logService.addFoodLog(
        FoodLog(
          food: portion.toFoodModel(
            id: logged?.id ?? _logService.newFoodLogId(),
            userId: userId,
            createdAt: logged?.food.createdAt ?? now,
          ),
          mealType: _meal,
          loggedAt: logged?.loggedAt ?? AppDateUtils.atTimeOf(_date, now),
        ),
      );
    });
  }

  Future<void> remove(CatalogFood food) async {
    final logged = loggedEntryOf(food);
    if (logged == null || isSaving(food)) return;

    return _save(food, () => _logService.deleteFoodLog(logged.id));
  }

  Future<void> _save(CatalogFood food, Future<void> Function() action) async {
    final key = food.displayName;
    _saving.add(key);
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
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
    _searchTimer?.cancel();
    _subscription?.cancel();
    _customSubscription?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';
import 'package:floww/core/nutrition/models/nutrient_input.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';

class FoodScanResultViewModel extends ChangeNotifier {
  FoodScanResultViewModel(this._food, this._goal, this._logService, this._date);

  static const _macroNutrients = [
    FoodNutrient.calories,
    FoodNutrient.protein,
    FoodNutrient.carbs,
    FoodNutrient.fat,
  ];

  static const _microNutrients = [
    FoodNutrient.fiber,
    FoodNutrient.sugar,
    FoodNutrient.sodium,
    FoodNutrient.water,
  ];

  final NutritionGoal _goal;
  final NutritionLogService _logService;
  final DateTime _date;

  FoodModel _food;
  bool _isEditing = false;
  bool _isEdited = false;
  bool _isSaving = false;
  bool _disposed = false;
  String? _errorMessage;
  String _draftName = '';
  final Map<FoodNutrient, String> _seedTexts = {};
  final Map<FoodNutrient, String> _draftTexts = {};

  FoodModel get food => _food;

  bool get isEditing => _isEditing;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  bool get canSave =>
      !_isSaving && (!_isEditing || _draftName.trim().isNotEmpty);

  MacroNutrients get _macros => _food.nutrition.macros;

  String get mealName => _isEdited ? _food.name : '${_food.name} (estimated)';

  String get caloriesLabel => NumberFormatter.grouped(_macros.calories.round());

  String get dailyGoalLabel =>
      '${(_macros.calories / _goal.calories * 100).round()}%';

  String get proteinLabel => _amountLabel(FoodNutrient.protein);

  String get carbsLabel => _amountLabel(FoodNutrient.carbs);

  String get fatLabel => _amountLabel(FoodNutrient.fat);

  List<MicronutrientProgress> get micronutrients => [
    for (final nutrient in _microNutrients)
      MicronutrientProgress(
        label: nutrient.label,
        amount: _amountLabel(nutrient),
        goal: '${_goalOf(nutrient)}${nutrient.unit}',
        progress: (_valueOf(nutrient) / _goalOf(nutrient)).clamp(0.0, 1.0),
      ),
  ];

  String get draftName => _draftName;

  List<NutrientInput> get macroInputs => _macroNutrients.map(_inputOf).toList();

  List<NutrientInput> get microInputs => _microNutrients.map(_inputOf).toList();

  void startEditing() {
    _draftName = _food.name;
    for (final nutrient in FoodNutrient.values) {
      final text = _formatInput(_valueOf(nutrient));
      _seedTexts[nutrient] = text;
      _draftTexts[nutrient] = text;
    }
    _errorMessage = null;
    _isEditing = true;
    notifyListeners();
  }

  void updateName(String value) {
    final couldSave = canSave;
    _draftName = value;
    if (canSave != couldSave) notifyListeners();
  }

  void updateNutrient(FoodNutrient nutrient, String value) =>
      _draftTexts[nutrient] = value;

  void finishEditing() {
    _applyDraft();
    _errorMessage = null;
    _isEditing = false;
    notifyListeners();
  }

  Future<bool> addToLog() async {
    if (!canSave) return false;
    if (_isEditing) _applyDraft();
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loggedAt = AppDateUtils.atTimeOf(_date, DateTime.now());
      await _logService.addFoodLog(
        FoodLog(
          food: _food,
          mealType: MealType.forTime(loggedAt),
          loggedAt: loggedAt,
        ),
      );
      return true;
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _applyDraft() {
    final draftName = _draftName.trim();
    final name = draftName.isEmpty ? _food.name : draftName;
    final valuesChanged = FoodNutrient.values.any(
      (nutrient) => _draftTexts[nutrient] != _seedTexts[nutrient],
    );
    if (name == _food.name && !valuesChanged) return;

    double resolve(FoodNutrient nutrient) {
      final text = _draftTexts[nutrient];
      if (text == _seedTexts[nutrient]) return _valueOf(nutrient);
      return double.tryParse(text ?? '') ?? 0;
    }

    _food = _food.copyWith(
      name: name,
      nutrition: _food.nutrition.copyWith(
        macros: _macros.copyWith(
          calories: resolve(FoodNutrient.calories),
          proteinG: resolve(FoodNutrient.protein),
          carbsG: resolve(FoodNutrient.carbs),
          fatG: resolve(FoodNutrient.fat),
          fiberG: resolve(FoodNutrient.fiber),
          sugarG: resolve(FoodNutrient.sugar),
          waterMl: resolve(FoodNutrient.water),
        ),
        minerals: _food.nutrition.minerals.copyWith(
          sodiumMg: resolve(FoodNutrient.sodium),
        ),
      ),
    );
    _isEdited = true;
  }

  NutrientInput _inputOf(FoodNutrient nutrient) => NutrientInput(
    nutrient: nutrient,
    text: _draftTexts[nutrient] ?? _formatInput(_valueOf(nutrient)),
  );

  String _amountLabel(FoodNutrient nutrient) =>
      '${_valueOf(nutrient).round()}${nutrient.unit}';

  double _valueOf(FoodNutrient nutrient) => switch (nutrient) {
    FoodNutrient.calories => _macros.calories,
    FoodNutrient.protein => _macros.proteinG,
    FoodNutrient.carbs => _macros.carbsG,
    FoodNutrient.fat => _macros.fatG,
    FoodNutrient.fiber => _macros.fiberG,
    FoodNutrient.sugar => _macros.sugarG,
    FoodNutrient.sodium => _food.nutrition.minerals.sodiumMg,
    FoodNutrient.water => _macros.waterMl,
  };

  int _goalOf(FoodNutrient nutrient) => switch (nutrient) {
    FoodNutrient.calories => _goal.calories,
    FoodNutrient.protein => _goal.proteinG,
    FoodNutrient.carbs => _goal.carbsG,
    FoodNutrient.fat => _goal.fatsG,
    FoodNutrient.fiber => _goal.fiberG,
    FoodNutrient.sugar => _goal.sugarG,
    FoodNutrient.sodium => _goal.sodiumMg,
    FoodNutrient.water => _goal.waterMl,
  };

  static String _formatInput(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
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

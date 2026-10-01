import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/food_photo_source.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';
import 'package:floww/core/nutrition/models/nutrient_input.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/portion_unit.dart';
import 'package:floww/core/nutrition/providers/food_photo_provider.dart';
import 'package:floww/core/nutrition/services/custom_food_service.dart';
import 'package:floww/core/nutrition/services/food_image_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/portion_selection.dart';

class FoodScanResultViewModel extends ChangeNotifier {
  FoodScanResultViewModel(
    FoodModel food,
    this._goal,
    this._logService,
    this._date, {
    this._meal,
    CustomFoodService? customFoodService,
    this._photo,
    this._photos,
  }) : _customFoodService = customFoodService ?? CustomFoodService(),
       _baseFood = food,
       _food = food,
       portion = PortionSelection(
         serving: food.servingDescription,
         weightG: food.servingWeightG,
       ) {
    _rescale();
  }

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
  final CustomFoodService _customFoodService;
  final DateTime _date;
  final MealType? _meal;
  final Uint8List? _photo;
  final FoodPhotoProvider? _photos;

  final PortionSelection portion;
  FoodModel _baseFood;
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
      !_isSaving &&
      portion.isValid &&
      (!_isEditing || _draftName.trim().isNotEmpty);

  String get portionHint => 'WAVE estimated ${portion.baseLabel}';

  String get servingLabel => portion.summaryLabel;

  String get editSubtitle => 'Values for ${portion.summaryLabel}';

  MacroNutrients get _macros => _food.nutrition.macros;

  bool get _isDescribed => _food.source == FoodSource.described;

  String get title => _isDescribed ? 'WAVE Estimate' : 'AI Food Scan';

  String get subtitle => _isDescribed
      ? 'WAVE estimated your meal from its description'
      : 'WAVE analyses your meal photo';

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

  void selectUnit(PortionUnit unit) =>
      _updatePortion(() => portion.selectUnit(unit));

  void selectPreset(double value) =>
      _updatePortion(() => portion.setAmount(value));

  void updateAmount(String text) =>
      _updatePortion(() => portion.updateAmount(text));

  void incrementPortion() => _updatePortion(portion.increment);

  void decrementPortion() => _updatePortion(portion.decrement);

  void _updatePortion(VoidCallback change) {
    change();
    _rescale();
    notifyListeners();
  }

  void _rescale() {
    _food = _baseFood.scaled(
      portion.factor,
      servingDescription: portion.servingLabel,
    );
  }

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
          mealType: _meal ?? MealType.forTime(loggedAt),
          loggedAt: loggedAt,
        ),
      );
      unawaited(_saveToMyFoods());
      unawaited(_savePhoto());
      return true;
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _saveToMyFoods() async {
    try {
      await _customFoodService.saveEstimate(
        CustomFoodDraft.fromFood(_baseFood),
      );
    } catch (e) {
      debugPrint('save estimate to my foods failed: $e');
    }
  }

  Future<void> _savePhoto() async {
    final photo = _photo;
    final photos = _photos;
    if (photo == null || photos == null) return;
    try {
      await photos.savePhoto(_food.name, photo, FoodPhotoSource.scan);
    } on FoodImageException catch (e) {
      debugPrint('save scan photo failed: $e');
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

    final edited = _food.copyWith(
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
    final factor = portion.factor;
    _baseFood = factor > 0
        ? edited.scaled(
            1 / factor,
            servingDescription: _baseFood.servingDescription,
          )
        : edited;
    _rescale();
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

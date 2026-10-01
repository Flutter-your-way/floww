import 'package:flutter/foundation.dart';
import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_portion_result.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/portion_unit.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';
import 'package:floww/core/nutrition/view_models/portion_selection.dart';

class FoodPortionViewModel extends ChangeNotifier {
  FoodPortionViewModel({required this.food, required this.meal, this.logged})
    : portion = PortionSelection(
        serving: food.serving,
        weightG: food.weightG,
        servings: logged == null ? 1 : food.servingsOf(logged.food),
      );

  final CatalogFood food;
  final MealType meal;
  final FoodLog? logged;
  final PortionSelection portion;

  bool get isEditing => logged != null;

  String get title => food.name;

  String get subtitle => portion.baseLabel;

  double get _factor => portion.factor;

  String get caloriesLabel => NutritionLabels.kcal(food.calories * _factor);

  String get proteinLabel =>
      NutritionLabels.preciseGrams(food.proteinG * _factor);

  String get carbsLabel => NutritionLabels.preciseGrams(food.carbsG * _factor);

  String get fatLabel => NutritionLabels.preciseGrams(food.fatG * _factor);

  String get microsLabel => NutritionLabels.microLine(
    food.fiberG * _factor,
    food.sugarG * _factor,
    food.sodiumMg * _factor,
  );

  String get primaryLabel => isEditing ? 'Update' : 'Add to ${meal.label}';

  FoodPortionResult? get result => portion.isValid
      ? FoodPortionResult.save(
          food.scaled(_factor, serving: portion.servingLabel),
        )
      : null;

  void selectUnit(PortionUnit unit) => _update(() => portion.selectUnit(unit));

  void selectPreset(double value) => _update(() => portion.setAmount(value));

  void updateAmount(String text) => _update(() => portion.updateAmount(text));

  void increment() => _update(portion.increment);

  void decrement() => _update(portion.decrement);

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }
}

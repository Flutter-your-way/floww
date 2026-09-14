import 'package:floww/core/nutrition/models/flow_category.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/water_log.dart';

enum DayLogStatus { full, partial, none }

class NutritionDay {
  NutritionDay({
    required this.date,
    required this.goal,
    List<FoodLog> foodLogs = const [],
    List<WaterLog> waterLogs = const [],
  }) : foodLogs = List.unmodifiable(foodLogs),
       waterLogs = List.unmodifiable(waterLogs);

  static const double _closenessTolerance = 0.1;
  static const double _closenessFalloff = 0.4;
  static const int _fullDayMeals = 3;

  final DateTime date;
  final NutritionGoal goal;
  final List<FoodLog> foodLogs;
  final List<WaterLog> waterLogs;

  double _sum(double Function(MacroNutrients macros) pick) =>
      foodLogs.fold(0, (total, log) => total + pick(log.macros));

  double get calories => _sum((macros) => macros.calories);

  double get proteinG => _sum((macros) => macros.proteinG);

  double get carbsG => _sum((macros) => macros.carbsG);

  double get fatG => _sum((macros) => macros.fatG);

  double get fiberG => _sum((macros) => macros.fiberG);

  double get sugarG => _sum((macros) => macros.sugarG);

  double get foodWaterMl => _sum((macros) => macros.waterMl);

  double get sodiumMg => foodLogs.fold(
    0,
    (total, log) => total + log.food.nutrition.minerals.sodiumMg,
  );

  double get drinkWaterMl =>
      waterLogs.fold(0, (total, log) => total + log.amountMl);

  double get waterMl => foodWaterMl + drinkWaterMl;

  MacroSplit get macroSplit =>
      MacroSplit(proteinG: proteinG, carbsG: carbsG, fatG: fatG);

  int goalGramsOf(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => goal.proteinG,
    MacroNutrient.carbs => goal.carbsG,
    MacroNutrient.fats => goal.fatsG,
  };

  bool get hasFood => foodLogs.isNotEmpty;

  bool get hasLogs => hasFood || waterLogs.isNotEmpty;

  List<FoodLog> logsFor(MealType meal) =>
      foodLogs.where((log) => log.mealType == meal).toList();

  double caloriesFor(MealType meal) => logsFor(
    meal,
  ).fold(0, (total, log) => total + log.macros.calories);

  Set<MealType> get loggedMeals =>
      foodLogs.map((log) => log.mealType).toSet();

  DayLogStatus get logStatus {
    final meals = loggedMeals.length;
    if (meals == 0) return DayLogStatus.none;
    return meals >= _fullDayMeals ? DayLogStatus.full : DayLogStatus.partial;
  }

  int pointsFor(FlowCategory category) {
    final max = category.maxPerDay;
    if (category == FlowCategory.water) {
      return _progressPoints(waterMl / goal.waterMl, max);
    }
    if (!hasFood) return 0;
    return switch (category) {
      FlowCategory.calories => _closenessPoints(calories / goal.calories, max),
      FlowCategory.protein => _progressPoints(proteinG / goal.proteinG, max),
      FlowCategory.carbs => _closenessPoints(carbsG / goal.carbsG, max),
      FlowCategory.fats => _closenessPoints(fatG / goal.fatsG, max),
      FlowCategory.fiber => _progressPoints(fiberG / goal.fiberG, max),
      FlowCategory.mealTiming => (loggedMeals.length ~/ 2).clamp(0, max),
      FlowCategory.sugar => sugarG <= goal.sugarG ? max : 0,
      FlowCategory.sodium => sodiumMg <= goal.sodiumMg ? max : 0,
      FlowCategory.water => 0,
    };
  }

  int get totalFlowPoints => FlowCategory.values.fold(
    0,
    (total, category) => total + pointsFor(category),
  );

  static int _progressPoints(double ratio, int max) =>
      (ratio.clamp(0.0, 1.0) * max).floor();

  static int _closenessPoints(double ratio, int max) {
    final deviation = (1 - ratio).abs();
    final score = 1 - (deviation - _closenessTolerance) / _closenessFalloff;
    return (score.clamp(0.0, 1.0) * max).floor();
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/flow_category.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/water_log.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  const goal = NutritionGoal.defaults;
  final date = DateTime(2026, 8, 3);

  DateTime at(int hour) => DateTime(2026, 8, 3, hour);

  test('totals combine every food log and drink', () {
    final day = NutritionDay(
      date: date,
      goal: goal,
      foodLogs: [
        testFoodLog(id: 'a', meal: MealType.breakfast, at: at(8), calories: 400, proteinG: 30, sodiumMg: 200, waterMl: 150),
        testFoodLog(id: 'b', meal: MealType.lunch, at: at(13), calories: 600, proteinG: 45, sodiumMg: 500, waterMl: 100),
      ],
      waterLogs: [WaterLog(id: 'w', amountMl: 500, loggedAt: at(10))],
    );

    expect(day.calories, 1000);
    expect(day.proteinG, 75);
    expect(day.sodiumMg, 700);
    expect(day.foodWaterMl, 250);
    expect(day.drinkWaterMl, 500);
    expect(day.waterMl, 750);
    expect(day.caloriesFor(MealType.lunch), 600);
    expect(day.logsFor(MealType.dinner), isEmpty);
  });

  test('log status depends on how many meals were logged', () {
    NutritionDay withMeals(List<MealType> meals) => NutritionDay(
      date: date,
      goal: goal,
      foodLogs: [
        for (final meal in meals)
          testFoodLog(id: meal.name, meal: meal, at: at(12), calories: 100),
      ],
    );

    expect(withMeals([]).logStatus, DayLogStatus.none);
    expect(withMeals([MealType.lunch]).logStatus, DayLogStatus.partial);
    expect(
      withMeals([MealType.breakfast, MealType.lunch, MealType.dinner]).logStatus,
      DayLogStatus.full,
    );
  });

  test('a day that hits every goal earns all 25 flow points', () {
    final day = NutritionDay(
      date: date,
      goal: goal,
      foodLogs: [
        testFoodLog(id: 'b', meal: MealType.breakfast, at: at(8), calories: 600, proteinG: 50, carbsG: 80, fatG: 20, fiberG: 8, sugarG: 10, sodiumMg: 500),
        testFoodLog(id: 'l', meal: MealType.lunch, at: at(13), calories: 800, proteinG: 70, carbsG: 100, fatG: 30, fiberG: 10, sugarG: 10, sodiumMg: 700),
        testFoodLog(id: 'd', meal: MealType.dinner, at: at(19), calories: 800, proteinG: 60, carbsG: 100, fatG: 30, fiberG: 8, sugarG: 10, sodiumMg: 600),
        testFoodLog(id: 's', meal: MealType.snacks, at: at(16), calories: 250, proteinG: 20, carbsG: 30, fatG: 10, fiberG: 4, sugarG: 10, sodiumMg: 100),
      ],
      waterLogs: [WaterLog(id: 'w', amountMl: 2500, loggedAt: at(12))],
    );

    for (final category in FlowCategory.values) {
      expect(day.pointsFor(category), category.maxPerDay, reason: category.label);
    }
    expect(day.totalFlowPoints, FlowCategory.dailyMax);
    expect(FlowCategory.dailyMax, 25);
  });

  test('partial progress earns partial points and limits are enforced', () {
    final day = NutritionDay(
      date: date,
      goal: goal,
      foodLogs: [
        testFoodLog(id: 'l', meal: MealType.lunch, at: at(13), calories: 1837.5, proteinG: 114, carbsG: 310, fatG: 90, sugarG: 60, sodiumMg: 1000),
      ],
    );

    expect(day.pointsFor(FlowCategory.calories), 3);
    expect(day.pointsFor(FlowCategory.protein), 2);
    expect(day.pointsFor(FlowCategory.carbs), 3);
    expect(day.pointsFor(FlowCategory.mealTiming), 0);
    expect(day.pointsFor(FlowCategory.water), 0);
    expect(day.pointsFor(FlowCategory.sugar), 0);
    expect(day.pointsFor(FlowCategory.sodium), 1);
  });

  test('water alone only earns water points', () {
    final day = NutritionDay(
      date: date,
      goal: goal,
      waterLogs: [WaterLog(id: 'w', amountMl: 2500, loggedAt: at(9))],
    );

    expect(day.hasFood, isFalse);
    expect(day.hasLogs, isTrue);
    expect(day.totalFlowPoints, FlowCategory.water.maxPerDay);
  });

  test('macro split shares add up to the whole day', () {
    final day = NutritionDay(
      date: date,
      goal: goal,
      foodLogs: [
        testFoodLog(id: 'l', meal: MealType.lunch, at: at(13), proteinG: 25, carbsG: 50, fatG: 10),
      ],
    );
    final split = day.macroSplit;

    expect(split.shareOf(MacroNutrient.protein), closeTo(100 / 390, 1e-9));
    expect(split.shareOf(MacroNutrient.fats), closeTo(90 / 390, 1e-9));
    expect(
      MacroNutrient.values.fold<double>(0, (sum, m) => sum + split.shareOf(m)),
      closeTo(1, 1e-9),
    );
    expect(
      NutritionDay(date: date, goal: goal).macroSplit.shareOf(MacroNutrient.carbs),
      0,
    );
  });
}

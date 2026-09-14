import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrient_input.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/food_scan_result_view_model.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  late FoodModel food;
  final date = DateTime(2026, 8, 3);

  setUpAll(() {
    food = FoodModel.fromJson(
      jsonDecode(File('test/fixtures/food_model.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  FoodScanResultViewModel build(FakeNutritionLogService service) =>
      FoodScanResultViewModel(food, NutritionGoal.defaults, service, date);

  test('review labels come from the scanned food and daily goals', () {
    final viewModel = build(FakeNutritionLogService());

    expect(viewModel.mealName, 'Grilled chicken rice bowl (estimated)');
    expect(viewModel.caloriesLabel, '567');
    expect(viewModel.dailyGoalLabel, '23%');
    expect(viewModel.proteinLabel, '53g');
    expect(viewModel.carbsLabel, '58g');
    expect(viewModel.fatLabel, '12g');

    final micros = viewModel.micronutrients;
    expect(micros.map((item) => item.label), [
      'Fiber',
      'Sugar',
      'Sodium',
      'Water',
    ]);
    expect(micros.first.amount, '3g');
    expect(micros.first.goal, '30g');
    expect(micros.first.progress, closeTo(3.2 / 30, 1e-9));
    expect(micros[2].amount, '0mg');
    expect(micros[2].goal, '2300mg');
    expect(micros.last.amount, '271ml');
    expect(micros.last.goal, '2500ml');
  });

  test('editing seeds the inputs with the current values', () {
    final viewModel = build(FakeNutritionLogService())..startEditing();

    expect(viewModel.isEditing, isTrue);
    expect(viewModel.draftName, 'Grilled chicken rice bowl');
    expect(
      viewModel.macroInputs.map((input) => (input.nutrient, input.text)),
      [
        (FoodNutrient.calories, '567'),
        (FoodNutrient.protein, '53'),
        (FoodNutrient.carbs, '58.2'),
        (FoodNutrient.fat, '11.9'),
      ],
    );
    expect(viewModel.microInputs.map((input) => input.nutrient), [
      FoodNutrient.fiber,
      FoodNutrient.sugar,
      FoodNutrient.sodium,
      FoodNutrient.water,
    ]);
  });

  test('going back applies edits and keeps untouched values exact', () {
    final viewModel = build(FakeNutritionLogService())
      ..startEditing()
      ..updateName('  Mixed Salad Bowl ')
      ..updateNutrient(FoodNutrient.calories, '480')
      ..updateNutrient(FoodNutrient.water, '150')
      ..finishEditing();

    expect(viewModel.isEditing, isFalse);
    expect(viewModel.mealName, 'Mixed Salad Bowl');
    expect(viewModel.caloriesLabel, '480');
    expect(viewModel.food.nutrition.macros.waterMl, 150);
    expect(viewModel.food.nutrition.macros.carbsG, 58.2);
    expect(viewModel.food.nutrition.minerals.sodiumMg, 0);
  });

  test('going back without changes keeps the estimate label', () {
    final viewModel = build(FakeNutritionLogService())
      ..startEditing()
      ..finishEditing();

    expect(viewModel.mealName, 'Grilled chicken rice bowl (estimated)');
    expect(viewModel.food, same(food));
  });

  test('a blank meal name blocks saving while editing', () {
    final viewModel = build(FakeNutritionLogService())..startEditing();

    viewModel.updateName('   ');
    expect(viewModel.canSave, isFalse);

    viewModel.updateName('Salad');
    expect(viewModel.canSave, isTrue);
  });

  test('add to log saves the edited food on the selected day', () async {
    final service = FakeNutritionLogService();
    final viewModel = build(service)
      ..startEditing()
      ..updateNutrient(FoodNutrient.protein, '28')
      ..updateNutrient(FoodNutrient.sodium, '320');

    final saved = await viewModel.addToLog();

    expect(saved, isTrue);
    expect(viewModel.isSaving, isFalse);
    final log = service.foodLogs.single;
    expect(log.id, food.id);
    expect(log.macros.proteinG, 28);
    expect(log.food.nutrition.minerals.sodiumMg, 320);
    expect(log.macros.calories, 567);
    expect(log.loggedAt.day, 3);
    expect(log.mealType, MealType.forTime(log.loggedAt));
  });

  test('add to log from review saves the scan unchanged', () async {
    final service = FakeNutritionLogService();
    final viewModel = build(service);

    expect(await viewModel.addToLog(), isTrue);
    expect(service.foodLogs.single.food, same(food));
  });

  test('a failed save shows the error and allows retry', () async {
    final viewModel = build(
      FakeNutritionLogService(
        addError: NutritionLogException(
          'Could not save this meal. Please try again.',
        ),
      ),
    );

    final saved = await viewModel.addToLog();

    expect(saved, isFalse);
    expect(
      viewModel.errorMessage,
      'Could not save this meal. Please try again.',
    );
    expect(viewModel.isSaving, isFalse);
    expect(viewModel.canSave, isTrue);
  });
}

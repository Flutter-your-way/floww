import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/view_models/log_food_view_model.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  final date = DateTime(2026, 8, 3);
  final chicken = FoodCatalog.items.firstWhere(
    (food) => food.name == 'Chicken Breast',
  );

  test('adding a catalog food logs it to the selected meal and day', () async {
    final service = FakeNutritionLogService();
    final viewModel = LogFoodViewModel(service, date, MealType.lunch);
    await pumpEventQueue();

    await viewModel.add(chicken);
    await pumpEventQueue();

    final log = service.foodLogs.single;
    expect(log.mealType, MealType.lunch);
    expect(log.loggedAt.year, 2026);
    expect(log.loggedAt.month, 8);
    expect(log.loggedAt.day, 3);
    expect(log.food.source, FoodSource.manual);
    expect(log.food.userId, 'user-1');
    expect(log.macros.calories, 165);
    expect(log.food.nutrition.minerals.sodiumMg, 74);
    expect(viewModel.isAdded(chicken), isTrue);
    expect(viewModel.errorMessage, isNull);

    await viewModel.add(chicken);
    expect(service.foodLogs, hasLength(1));
    viewModel.dispose();
  });

  test('added state is per meal', () async {
    final service = FakeNutritionLogService();
    final viewModel = LogFoodViewModel(service, date, MealType.lunch);
    await viewModel.add(chicken);
    await pumpEventQueue();

    viewModel.selectMeal(MealType.dinner);

    expect(viewModel.isAdded(chicken), isFalse);
    viewModel.dispose();
  });

  test('search filters the catalog by name', () {
    final viewModel = LogFoodViewModel(
      FakeNutritionLogService(),
      date,
      MealType.breakfast,
    );

    viewModel.search('  yog ');

    expect(viewModel.results.map((food) => food.name), ['Greek Yogurt']);
    expect(viewModel.caloriesLabelOf(viewModel.results.first), '130 kcal');
    expect(
      viewModel.macrosLabelOf(chicken),
      'P:31g · C:0g · F:3.6g',
    );

    viewModel.search('zzz');
    expect(viewModel.results, isEmpty);
    viewModel.dispose();
  });

  test('signed-out users see an error instead of a silent failure', () async {
    final service = FakeNutritionLogService(userId: null);
    final viewModel = LogFoodViewModel(service, date, MealType.snacks);

    await viewModel.add(chicken);

    expect(service.foodLogs, isEmpty);
    expect(viewModel.errorMessage, 'Please sign in again.');
    expect(viewModel.isSaving(chicken), isFalse);
    viewModel.dispose();
  });
}

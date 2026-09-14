import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/home/providers/home_provider.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/water_log.dart';

import 'fakes/fake_nutrition_log_service.dart';

void main() {
  DateTime todayAt(int hour) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour);
  }

  test('home nutrition summary reflects only today\'s logs', () async {
    final service = FakeNutritionLogService();
    service.foodLogs.addAll([
      testFoodLog(id: 'today', meal: MealType.lunch, at: todayAt(12), calories: 480, proteinG: 28, carbsG: 52, fatG: 15),
      testFoodLog(
        id: 'yesterday',
        meal: MealType.dinner,
        at: todayAt(19).subtract(const Duration(days: 1)),
        calories: 900,
        proteinG: 60,
      ),
    ]);
    final provider = HomeProvider(service);
    await pumpEventQueue();

    expect(provider.nutrition.totalCalories, 480);
    expect(provider.nutrition.proteinG, 28);
    expect(provider.nutrition.carbsG, 52);
    expect(provider.nutrition.fatsG, 15);
    expect(provider.nutrition.calorieGoal, 2450);
    expect(
      provider.todayProgress.items
          .firstWhere((item) => item.label == 'Nutrition')
          .fraction,
      '0/1',
    );
    provider.dispose();
  });

  test('scanning more food raises the home stats live', () async {
    final service = FakeNutritionLogService();
    final provider = HomeProvider(service);
    await pumpEventQueue();
    expect(provider.nutrition.totalCalories, 0);

    await service.addFoodLog(
      testFoodLog(id: 'big', meal: MealType.lunch, at: todayAt(13), calories: 2300),
    );
    await service.addWaterLog(2500, todayAt(10));
    await pumpEventQueue();

    expect(provider.nutrition.totalCalories, 2300);
    final water = provider.habits.first;
    expect(water.valueLabel, '2.5L / 2.5L Target');
    expect(water.completed, isTrue);
    final progress = provider.todayProgress;
    expect(
      progress.items.firstWhere((item) => item.label == 'Nutrition').isComplete,
      isTrue,
    );
    expect(progress.completedCount, 2);
    expect(progress.totalCount, 6);
    provider.dispose();
  });

  test('water from drinks and food both count toward the habit', () async {
    final service = FakeNutritionLogService();
    service.foodLogs.add(
      testFoodLog(id: 'soup', meal: MealType.dinner, at: todayAt(19), waterMl: 400),
    );
    service.waterLogs.add(
      WaterLog(id: 'glass', amountMl: 600, loggedAt: todayAt(9)),
    );
    final provider = HomeProvider(service);
    await pumpEventQueue();

    expect(provider.habits.first.valueLabel, '1.0L / 2.5L Target');
    expect(provider.habits.first.completed, isFalse);
    provider.dispose();
  });
}

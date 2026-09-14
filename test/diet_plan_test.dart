import 'package:flutter_test/flutter_test.dart';

import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';

void main() {
  final start = DateTime(2026, 7, 26, 15, 30);

  test('generates 30 consecutive days of four meals', () {
    final plan = DietPlan.generate(startDate: start, targetCalories: 2450);

    expect(plan.startDate, DateTime(2026, 7, 26));
    expect(plan.days, hasLength(DietPlan.lengthDays));
    for (final day in plan.days) {
      expect(day.date, DateTime(2026, 7, 26 + day.dayNumber - 1));
      expect(day.meals.map((meal) => meal.mealType), MealType.values);
    }
    expect(plan.endDate, DateTime(2026, 8, 25));
  });

  test('daily calories stay close to the target on average', () {
    final plan = DietPlan.generate(startDate: start, targetCalories: 2200);
    final average =
        plan.days.fold(0, (total, day) => total + day.calories) /
        plan.days.length;

    expect(average, closeTo(2200, 2200 * 0.05));
    expect(plan.days.map((day) => day.calories).toSet().length, greaterThan(1));
  });

  test('the same start and target always produce the same plan', () {
    final first = DietPlan.generate(startDate: start, targetCalories: 2450);
    final second = DietPlan.generate(startDate: start, targetCalories: 2450);

    expect(
      first.days.map((day) => day.meals.map((meal) => meal.name).join('|')),
      second.days.map((day) => day.meals.map((meal) => meal.name).join('|')),
    );
  });

  test('maps calendar dates to plan day numbers', () {
    final plan = DietPlan.generate(startDate: start, targetCalories: 2450);

    expect(plan.dayNumberFor(DateTime(2026, 7, 26, 23)), 1);
    expect(plan.dayNumberFor(DateTime(2026, 7, 28)), 3);
    expect(plan.dayNumberFor(DateTime(2026, 7, 25)), 0);
  });
}

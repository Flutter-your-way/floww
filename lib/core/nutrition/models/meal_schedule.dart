import 'package:floww/core/nutrition/models/meal_type.dart';

class MealSchedule {
  const MealSchedule(int mealsPerDay)
    : mealsPerDay = mealsPerDay < minMeals
          ? minMeals
          : mealsPerDay > maxMeals
          ? maxMeals
          : mealsPerDay;

  static const int minMeals = 3;
  static const int maxMeals = 5;
  static const int defaultMeals = 4;
  static const MealSchedule standard = MealSchedule(defaultMeals);
  static const List<int> options = [3, 4, 5];

  final int mealsPerDay;

  List<MealType> get meals => switch (mealsPerDay) {
    3 => const [MealType.breakfast, MealType.lunch, MealType.dinner],
    5 => const [
      MealType.breakfast,
      MealType.morningSnack,
      MealType.lunch,
      MealType.dinner,
      MealType.snacks,
    ],
    _ => const [
      MealType.breakfast,
      MealType.lunch,
      MealType.dinner,
      MealType.snacks,
    ],
  };

  List<MealType> mealsWith(Iterable<MealType> extra) {
    final included = {...meals, ...extra};
    return [
      for (final meal in MealType.values)
        if (included.contains(meal)) meal,
    ];
  }

  static int _weightOf(MealType meal) => switch (meal) {
    MealType.breakfast => 25,
    MealType.morningSnack => 10,
    MealType.lunch => 35,
    MealType.dinner => 30,
    MealType.snacks => 10,
  };

  Map<MealType, int> calorieTargets(int dailyCalories) {
    final meals = this.meals;
    final totalWeight = meals.fold<int>(
      0,
      (sum, meal) => sum + _weightOf(meal),
    );
    final targets = <MealType, int>{
      for (final meal in meals)
        meal: (dailyCalories * _weightOf(meal) / totalWeight).round(),
    };
    final drift =
        dailyCalories -
        targets.values.fold<int>(0, (sum, value) => sum + value);
    targets[MealType.lunch] = targets[MealType.lunch]! + drift;
    return targets;
  }

  int calorieTargetOf(MealType meal, int dailyCalories) =>
      calorieTargets(dailyCalories)[meal] ?? 0;
}

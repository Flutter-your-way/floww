import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';

class DietPlanMeal {
  const DietPlanMeal({
    required this.mealType,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final MealType mealType;
  final String name;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  DietPlanMeal scaled(double factor) => DietPlanMeal(
    mealType: mealType,
    name: name,
    calories: (calories * factor).round(),
    proteinG: (proteinG * factor).round(),
    carbsG: (carbsG * factor).round(),
    fatG: (fatG * factor).round(),
  );
}

class DietPlanDay {
  const DietPlanDay({
    required this.dayNumber,
    required this.date,
    required this.meals,
  });

  final int dayNumber;
  final DateTime date;
  final List<DietPlanMeal> meals;

  int _sum(int Function(DietPlanMeal meal) pick) =>
      meals.fold(0, (total, meal) => total + pick(meal));

  int get calories => _sum((meal) => meal.calories);

  int get proteinG => _sum((meal) => meal.proteinG);

  int get carbsG => _sum((meal) => meal.carbsG);

  int get fatG => _sum((meal) => meal.fatG);
}

class DietPlan {
  DietPlan._({
    required this.startDate,
    required this.targetCalories,
    required this.days,
  });

  factory DietPlan.generate({
    required DateTime startDate,
    required int targetCalories,
  }) {
    final start = AppDateUtils.dateOnly(startDate);
    final factor = targetCalories / _averageTemplateCalories;
    final days = List.generate(lengthDays, (index) {
      final meals = [
        _breakfasts[index % _variety],
        _lunches[(index * 2 + 1) % _variety],
        _dinners[(index * 3 + 2) % _variety],
        _snacks[(index + 3) % _variety],
      ];
      return DietPlanDay(
        dayNumber: index + 1,
        date: AppDateUtils.addDays(start, index),
        meals: meals.map((meal) => meal.scaled(factor)).toList(),
      );
    });
    return DietPlan._(
      startDate: start,
      targetCalories: targetCalories,
      days: days,
    );
  }

  static const int lengthDays = 30;
  static const int _variety = 5;

  final DateTime startDate;
  final int targetCalories;
  final List<DietPlanDay> days;

  DateTime get endDate => AppDateUtils.addDays(startDate, lengthDays);

  int dayNumberFor(DateTime date) =>
      AppDateUtils.daysBetween(startDate, date) + 1;

  static double get _averageTemplateCalories {
    int average(List<DietPlanMeal> meals) =>
        meals.fold(0, (total, meal) => total + meal.calories) ~/ meals.length;
    return (average(_breakfasts) +
            average(_lunches) +
            average(_dinners) +
            average(_snacks))
        .toDouble();
  }

  static const _breakfasts = [
    DietPlanMeal(mealType: MealType.breakfast, name: 'Oats with berries & almonds', calories: 380, proteinG: 14, carbsG: 58, fatG: 11),
    DietPlanMeal(mealType: MealType.breakfast, name: 'Greek yogurt parfait with granola', calories: 350, proteinG: 22, carbsG: 45, fatG: 9),
    DietPlanMeal(mealType: MealType.breakfast, name: 'Veggie omelette with toast', calories: 410, proteinG: 26, carbsG: 30, fatG: 20),
    DietPlanMeal(mealType: MealType.breakfast, name: 'Peanut butter banana toast', calories: 390, proteinG: 14, carbsG: 48, fatG: 16),
    DietPlanMeal(mealType: MealType.breakfast, name: 'Paneer bhurji with chapati', calories: 420, proteinG: 22, carbsG: 36, fatG: 20),
  ];

  static const _lunches = [
    DietPlanMeal(mealType: MealType.lunch, name: 'Grilled chicken & quinoa bowl', calories: 520, proteinG: 48, carbsG: 44, fatG: 14),
    DietPlanMeal(mealType: MealType.lunch, name: 'Lentil curry with brown rice', calories: 540, proteinG: 24, carbsG: 82, fatG: 12),
    DietPlanMeal(mealType: MealType.lunch, name: 'Turkey & avocado wrap', calories: 510, proteinG: 34, carbsG: 46, fatG: 20),
    DietPlanMeal(mealType: MealType.lunch, name: 'Tofu stir-fry with noodles', calories: 530, proteinG: 28, carbsG: 62, fatG: 18),
    DietPlanMeal(mealType: MealType.lunch, name: 'Tuna salad with sweet potato', calories: 480, proteinG: 36, carbsG: 44, fatG: 16),
  ];

  static const _dinners = [
    DietPlanMeal(mealType: MealType.dinner, name: 'Baked salmon & roasted veg', calories: 490, proteinG: 44, carbsG: 26, fatG: 22),
    DietPlanMeal(mealType: MealType.dinner, name: 'Chicken tikka with cauliflower rice', calories: 470, proteinG: 46, carbsG: 18, fatG: 22),
    DietPlanMeal(mealType: MealType.dinner, name: 'Beef & broccoli with rice', calories: 560, proteinG: 40, carbsG: 52, fatG: 20),
    DietPlanMeal(mealType: MealType.dinner, name: 'Chickpea & spinach curry', calories: 480, proteinG: 20, carbsG: 62, fatG: 16),
    DietPlanMeal(mealType: MealType.dinner, name: 'Shrimp pasta primavera', calories: 520, proteinG: 36, carbsG: 60, fatG: 14),
  ];

  static const _snacks = [
    DietPlanMeal(mealType: MealType.snacks, name: 'Apple & almond butter', calories: 220, proteinG: 6, carbsG: 28, fatG: 12),
    DietPlanMeal(mealType: MealType.snacks, name: 'Protein shake with banana', calories: 250, proteinG: 26, carbsG: 30, fatG: 3),
    DietPlanMeal(mealType: MealType.snacks, name: 'Hummus with carrot sticks', calories: 180, proteinG: 6, carbsG: 20, fatG: 9),
    DietPlanMeal(mealType: MealType.snacks, name: 'Cottage cheese & pineapple', calories: 190, proteinG: 20, carbsG: 18, fatG: 4),
    DietPlanMeal(mealType: MealType.snacks, name: 'Trail mix', calories: 210, proteinG: 6, carbsG: 18, fatG: 14),
  ];
}

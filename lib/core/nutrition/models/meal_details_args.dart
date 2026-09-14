import 'package:floww/core/nutrition/models/meal_type.dart';

class MealDetailsArgs {
  const MealDetailsArgs({required this.date, required this.meal});

  final DateTime date;
  final MealType meal;
}

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_model.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';

class FoodLog {
  const FoodLog({
    required this.food,
    required this.mealType,
    required this.loggedAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    final loggedAt = DateTime.parse(
      (json['loggedAt'] ?? json['createdAt']) as String,
    ).toLocal();
    return FoodLog(
      food: FoodModel.fromJson(json),
      mealType:
          MealType.values.asNameMap()[json['mealType']] ??
          MealType.forTime(loggedAt),
      loggedAt: loggedAt,
    );
  }

  final FoodModel food;
  final MealType mealType;
  final DateTime loggedAt;

  String get id => food.id;

  MacroNutrients get macros => food.nutrition.macros;

  Map<String, dynamic> toJson() => {
    ...food.toJson(),
    'mealType': mealType.name,
    'loggedAt': AppDateUtils.isoKey(loggedAt),
  };
}

import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_model.dart';

class CustomFood {
  const CustomFood({
    required this.id,
    required this.name,
    required this.serving,
    required this.weightG,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
    this.waterMl = 0,
    required this.createdAt,
  });

  factory CustomFood.fromJson(Map<String, dynamic> json) => CustomFood(
    id: json['id'] as String,
    name: json['name'] as String,
    serving: json['serving'] as String? ?? '',
    weightG: (json['weightG'] as num?)?.toDouble() ?? 0,
    calories: (json['calories'] as num?)?.toDouble() ?? 0,
    proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
    carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
    fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
    fiberG: (json['fiberG'] as num?)?.toDouble() ?? 0,
    sugarG: (json['sugarG'] as num?)?.toDouble() ?? 0,
    sodiumMg: (json['sodiumMg'] as num?)?.toDouble() ?? 0,
    waterMl: (json['waterMl'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final String id;
  final String name;
  final String serving;
  final double weightG;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final double waterMl;
  final DateTime createdAt;

  CatalogFood get catalog => CatalogFood(
    name: name,
    serving: serving.isEmpty ? '1 serving' : serving,
    weightG: weightG,
    calories: calories,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
    fiberG: fiberG,
    sugarG: sugarG,
    sodiumMg: sodiumMg,
    waterMl: waterMl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'serving': serving,
    'weightG': weightG,
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'fiberG': fiberG,
    'sugarG': sugarG,
    'sodiumMg': sodiumMg,
    'waterMl': waterMl,
    'createdAt': createdAt.toIso8601String(),
  };
}

class CustomFoodDraft {
  const CustomFoodDraft({
    required this.name,
    required this.serving,
    required this.weightG,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
    this.waterMl = 0,
  });

  factory CustomFoodDraft.fromFood(FoodModel food) {
    final macros = food.nutrition.macros;
    return CustomFoodDraft(
      name: food.name,
      serving: food.servingDescription,
      weightG: food.servingWeightG,
      calories: macros.calories,
      proteinG: macros.proteinG,
      carbsG: macros.carbsG,
      fatG: macros.fatG,
      fiberG: macros.fiberG,
      sugarG: macros.sugarG,
      sodiumMg: food.nutrition.minerals.sodiumMg,
      waterMl: macros.waterMl,
    );
  }

  final String name;
  final String serving;
  final double weightG;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final double waterMl;

  bool get isValid => name.trim().isNotEmpty && calories > 0;
}

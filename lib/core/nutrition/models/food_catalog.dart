import 'package:floww/core/nutrition/models/food_model.dart';

class CatalogFood {
  const CatalogFood({
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
    this.healthScore = 7,
  });

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
  final int healthScore;

  String get displayName => '$name ($serving)';

  bool matches(FoodModel food) =>
      food.source == FoodSource.manual &&
      food.name == name &&
      food.servingDescription == serving;

  FoodModel toFoodModel({
    required String id,
    required String userId,
    required DateTime createdAt,
  }) => FoodModel(
    id: id,
    userId: userId,
    name: name,
    description: '',
    servingDescription: serving,
    servingWeightG: weightG,
    confidence: 1,
    healthScore: healthScore,
    ingredients: [
      FoodIngredient(
        name: name,
        quantity: serving,
        weightG: weightG,
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      ),
    ],
    nutrition: FoodNutrition(
      macros: MacroNutrients(
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        fiberG: fiberG,
        sugarG: sugarG,
        addedSugarG: 0,
        saturatedFatG: 0,
        transFatG: 0,
        monounsaturatedFatG: 0,
        polyunsaturatedFatG: 0,
        cholesterolMg: 0,
        waterMl: waterMl,
      ),
      vitamins: Vitamins.zero,
      minerals: Minerals.zero.copyWith(sodiumMg: sodiumMg),
    ),
    source: FoodSource.manual,
    createdAt: createdAt.toUtc(),
  );
}

class FoodCatalog {
  FoodCatalog._();

  static const List<CatalogFood> items = [
    CatalogFood(name: 'Chicken Breast', serving: '100g', weightG: 100, calories: 165, proteinG: 31, carbsG: 0, fatG: 3.6, sodiumMg: 74, waterMl: 65, healthScore: 9),
    CatalogFood(name: 'Brown Rice', serving: '100g cooked', weightG: 100, calories: 111, proteinG: 2.6, carbsG: 23, fatG: 0.9, fiberG: 1.8, sugarG: 0.4, sodiumMg: 5, waterMl: 73, healthScore: 8),
    CatalogFood(name: 'Whole Eggs', serving: '2 eggs', weightG: 100, calories: 143, proteinG: 13, carbsG: 1, fatG: 10, sugarG: 0.4, sodiumMg: 142, waterMl: 76, healthScore: 8),
    CatalogFood(name: 'Greek Yogurt', serving: '200g', weightG: 200, calories: 130, proteinG: 22, carbsG: 9, fatG: 0.5, sugarG: 7, sodiumMg: 72, waterMl: 170, healthScore: 9),
    CatalogFood(name: 'Oats', serving: '100g dry', weightG: 100, calories: 389, proteinG: 17, carbsG: 66, fatG: 7, fiberG: 10.6, sodiumMg: 2, waterMl: 8, healthScore: 9),
    CatalogFood(name: 'Salmon', serving: '100g', weightG: 100, calories: 208, proteinG: 20, carbsG: 0, fatG: 13, sodiumMg: 59, waterMl: 65, healthScore: 9),
    CatalogFood(name: 'Banana', serving: '1 medium', weightG: 118, calories: 105, proteinG: 1.3, carbsG: 27, fatG: 0.4, fiberG: 3.1, sugarG: 14, sodiumMg: 1, waterMl: 88, healthScore: 8),
    CatalogFood(name: 'Apple', serving: '1 medium', weightG: 182, calories: 95, proteinG: 0.5, carbsG: 25, fatG: 0.3, fiberG: 4.4, sugarG: 19, sodiumMg: 2, waterMl: 156, healthScore: 8),
    CatalogFood(name: 'Avocado', serving: '½ medium', weightG: 68, calories: 109, proteinG: 1.4, carbsG: 5.8, fatG: 10, fiberG: 4.6, sugarG: 0.4, sodiumMg: 5, waterMl: 50, healthScore: 9),
    CatalogFood(name: 'Almonds', serving: '28g', weightG: 28, calories: 164, proteinG: 6, carbsG: 6, fatG: 14, fiberG: 3.5, sugarG: 1.2, waterMl: 1, healthScore: 8),
    CatalogFood(name: 'Whole Wheat Bread', serving: '1 slice', weightG: 32, calories: 81, proteinG: 4, carbsG: 14, fatG: 1.1, fiberG: 1.9, sugarG: 1.4, sodiumMg: 146, waterMl: 12, healthScore: 6),
    CatalogFood(name: 'Milk (2%)', serving: '1 cup', weightG: 244, calories: 122, proteinG: 8, carbsG: 12, fatG: 4.8, sugarG: 12, sodiumMg: 115, waterMl: 218, healthScore: 7),
    CatalogFood(name: 'Broccoli', serving: '1 cup', weightG: 91, calories: 31, proteinG: 2.5, carbsG: 6, fatG: 0.3, fiberG: 2.4, sugarG: 1.5, sodiumMg: 30, waterMl: 81, healthScore: 10),
    CatalogFood(name: 'Sweet Potato', serving: '1 medium', weightG: 130, calories: 112, proteinG: 2, carbsG: 26, fatG: 0.1, fiberG: 3.9, sugarG: 5.4, sodiumMg: 72, waterMl: 100, healthScore: 9),
    CatalogFood(name: 'Quinoa', serving: '1 cup cooked', weightG: 185, calories: 222, proteinG: 8, carbsG: 39, fatG: 3.6, fiberG: 5.2, sugarG: 1.6, sodiumMg: 13, waterMl: 133, healthScore: 9),
    CatalogFood(name: 'Firm Tofu', serving: '100g', weightG: 100, calories: 144, proteinG: 17, carbsG: 3, fatG: 9, fiberG: 2.3, sodiumMg: 14, waterMl: 70, healthScore: 9),
    CatalogFood(name: 'Lentils', serving: '1 cup cooked', weightG: 198, calories: 230, proteinG: 18, carbsG: 40, fatG: 0.8, fiberG: 15.6, sugarG: 3.6, sodiumMg: 4, waterMl: 139, healthScore: 10),
    CatalogFood(name: 'Paneer', serving: '100g', weightG: 100, calories: 265, proteinG: 18, carbsG: 3.6, fatG: 20, sodiumMg: 18, waterMl: 52, healthScore: 6),
    CatalogFood(name: 'White Rice', serving: '1 cup cooked', weightG: 158, calories: 205, proteinG: 4.3, carbsG: 45, fatG: 0.4, fiberG: 0.6, sugarG: 0.1, sodiumMg: 2, waterMl: 108, healthScore: 5),
    CatalogFood(name: 'Chapati', serving: '1 medium', weightG: 40, calories: 120, proteinG: 3.1, carbsG: 18, fatG: 3.7, fiberG: 2, sugarG: 0.4, sodiumMg: 119, waterMl: 13, healthScore: 6),
    CatalogFood(name: 'Peanut Butter', serving: '2 tbsp', weightG: 32, calories: 188, proteinG: 8, carbsG: 6, fatG: 16, fiberG: 1.9, sugarG: 3, sodiumMg: 147, healthScore: 6),
    CatalogFood(name: 'Orange Juice', serving: '1 cup', weightG: 248, calories: 112, proteinG: 1.7, carbsG: 26, fatG: 0.5, fiberG: 0.5, sugarG: 21, sodiumMg: 2, waterMl: 219, healthScore: 5),
    CatalogFood(name: 'Whey Protein Shake', serving: '1 scoop', weightG: 30, calories: 120, proteinG: 24, carbsG: 3, fatG: 1.5, sugarG: 1, sodiumMg: 50, healthScore: 7),
    CatalogFood(name: 'Mixed Greens', serving: '2 cups', weightG: 60, calories: 15, proteinG: 1.2, carbsG: 2.6, fatG: 0.2, fiberG: 1.3, sugarG: 0.4, sodiumMg: 47, waterMl: 55, healthScore: 10),
    CatalogFood(name: 'Olive Oil', serving: '1 tbsp', weightG: 14, calories: 119, proteinG: 0, carbsG: 0, fatG: 13.5, healthScore: 7),
    CatalogFood(name: 'Cottage Cheese', serving: '1 cup', weightG: 226, calories: 206, proteinG: 28, carbsG: 8, fatG: 9, sugarG: 6, sodiumMg: 700, waterMl: 180, healthScore: 7),
    CatalogFood(name: 'Pasta', serving: '1 cup cooked', weightG: 140, calories: 220, proteinG: 8, carbsG: 43, fatG: 1.3, fiberG: 2.5, sugarG: 0.8, sodiumMg: 1, waterMl: 87, healthScore: 5),
    CatalogFood(name: 'Beef Steak', serving: '100g', weightG: 100, calories: 271, proteinG: 25, carbsG: 0, fatG: 19, sodiumMg: 55, waterMl: 56, healthScore: 6),
    CatalogFood(name: 'Canned Tuna', serving: '100g', weightG: 100, calories: 116, proteinG: 26, carbsG: 0, fatG: 0.8, sodiumMg: 247, waterMl: 70, healthScore: 8),
    CatalogFood(name: 'Dark Chocolate', serving: '28g', weightG: 28, calories: 170, proteinG: 2.2, carbsG: 13, fatG: 12, fiberG: 3.1, sugarG: 6.8, sodiumMg: 6, healthScore: 4),
  ];

  static List<CatalogFood> search(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return items;
    return items
        .where((food) => food.name.toLowerCase().contains(term))
        .toList();
  }
}

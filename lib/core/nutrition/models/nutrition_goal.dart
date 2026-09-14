class NutritionGoal {
  const NutritionGoal({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.waterMl,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final int fiberG;
  final int sugarG;
  final int sodiumMg;
  final int waterMl;

  static const NutritionGoal defaults = NutritionGoal(
    calories: 2450,
    proteinG: 200,
    carbsG: 310,
    fatsG: 90,
    fiberG: 30,
    sugarG: 50,
    sodiumMg: 2300,
    waterMl: 2500,
  );
}

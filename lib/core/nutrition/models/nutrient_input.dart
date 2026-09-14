enum FoodNutrient {
  calories('Calories', 'kcal'),
  protein('Protein', 'g'),
  carbs('Carbs', 'g'),
  fat('Fat', 'g'),
  fiber('Fiber', 'g'),
  sugar('Sugar', 'g'),
  sodium('Sodium', 'mg'),
  water('Water', 'ml');

  const FoodNutrient(this.label, this.unit);

  final String label;
  final String unit;
}

class NutrientInput {
  const NutrientInput({required this.nutrient, required this.text});

  final FoodNutrient nutrient;
  final String text;
}

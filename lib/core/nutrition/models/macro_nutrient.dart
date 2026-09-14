enum MacroNutrient {
  protein(
    label: 'Protein',
    tabLabel: 'Protein',
    tagline: 'BUILD & REPAIR',
    kcalPerGram: 4,
    description:
        'Protein is essential for building and repairing muscle tissue, '
        'producing enzymes and hormones, and keeping you satiated. It has the '
        'highest thermic effect of any macronutrient — your body burns 20–30% '
        'of its calories just digesting it.',
    tips: [
      'Aim for 0.7–1g per lb of body weight',
      'Spread intake across 3–4 meals',
      'Prioritise lean sources: chicken, fish, eggs, Greek yogurt',
    ],
    recommendedRange: '25–35%',
  ),
  carbs(
    label: 'Carbs',
    tabLabel: 'Carbohydrates',
    tagline: 'PRIMARY FUEL',
    kcalPerGram: 4,
    description:
        'Carbohydrates are your body\'s preferred energy source, especially '
        'during intense exercise. They replenish muscle glycogen, support brain '
        'function, and spare protein from being used as fuel. Quality matters '
        '— favour complex carbs over refined sugars.',
    tips: [
      'Time carbs around workouts for best performance',
      'Choose whole grains, oats, sweet potato & fruit',
      'Limit added sugars to <10% of total calories',
    ],
    recommendedRange: '40–55%',
  ),
  fats(
    label: 'Fats',
    tabLabel: 'Fats',
    tagline: 'HORMONES & ABSORPTION',
    kcalPerGram: 9,
    description:
        'Dietary fat is crucial for hormone production (including '
        'testosterone), absorbing fat-soluble vitamins (A, D, E, K), and '
        'protecting organs. Despite being calorie-dense at 9 kcal/g, healthy '
        'fats are vital — especially omega-3s for inflammation and heart '
        'health.',
    tips: [
      'Include omega-3 sources: salmon, walnuts, flaxseed',
      'Minimise saturated fat, avoid trans fats',
      'Healthy sources: avocado, olive oil, nuts',
    ],
    recommendedRange: '20–35%',
  );

  const MacroNutrient({
    required this.label,
    required this.tabLabel,
    required this.tagline,
    required this.kcalPerGram,
    required this.description,
    required this.tips,
    required this.recommendedRange,
  });

  final String label;
  final String tabLabel;
  final String tagline;
  final int kcalPerGram;
  final String description;
  final List<String> tips;
  final String recommendedRange;
}

class MacroSplit {
  const MacroSplit({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;

  double gramsOf(MacroNutrient macro) => switch (macro) {
    MacroNutrient.protein => proteinG,
    MacroNutrient.carbs => carbsG,
    MacroNutrient.fats => fatG,
  };

  double caloriesOf(MacroNutrient macro) => gramsOf(macro) * macro.kcalPerGram;

  double shareOf(MacroNutrient macro) {
    final total = MacroNutrient.values.fold<double>(
      0,
      (sum, item) => sum + caloriesOf(item),
    );
    return total == 0 ? 0 : caloriesOf(macro) / total;
  }
}

import 'package:floww/core/nutrition/models/food_model.dart';

enum MicronutrientUnit {
  mg('mg'),
  mcg('mcg');

  const MicronutrientUnit(this.label);

  final String label;
}

enum Micronutrient {
  potassium('Potassium', MicronutrientUnit.mg, 4700),
  calcium('Calcium', MicronutrientUnit.mg, 1300),
  iron('Iron', MicronutrientUnit.mg, 18),
  magnesium('Magnesium', MicronutrientUnit.mg, 420),
  vitaminC('Vitamin C', MicronutrientUnit.mg, 90),
  vitaminD('Vitamin D', MicronutrientUnit.mcg, 20),
  vitaminA('Vitamin A', MicronutrientUnit.mcg, 900),
  vitaminB12('Vitamin B12', MicronutrientUnit.mcg, 2.4),
  zinc('Zinc', MicronutrientUnit.mg, 11),
  folate('Folate (B9)', MicronutrientUnit.mcg, 400),
  vitaminE('Vitamin E', MicronutrientUnit.mg, 15),
  vitaminK('Vitamin K', MicronutrientUnit.mcg, 120),
  vitaminB6('Vitamin B6', MicronutrientUnit.mg, 1.7),
  thiamin('Thiamin (B1)', MicronutrientUnit.mg, 1.2),
  riboflavin('Riboflavin (B2)', MicronutrientUnit.mg, 1.3),
  niacin('Niacin (B3)', MicronutrientUnit.mg, 16),
  pantothenicAcid('Pantothenic (B5)', MicronutrientUnit.mg, 5),
  biotin('Biotin (B7)', MicronutrientUnit.mcg, 30),
  choline('Choline', MicronutrientUnit.mg, 550),
  phosphorus('Phosphorus', MicronutrientUnit.mg, 1250),
  copper('Copper', MicronutrientUnit.mg, 0.9),
  manganese('Manganese', MicronutrientUnit.mg, 2.3),
  selenium('Selenium', MicronutrientUnit.mcg, 55),
  iodine('Iodine', MicronutrientUnit.mcg, 150);

  const Micronutrient(this.label, this.unit, this.dailyValue);

  static const int featuredCount = 8;

  final String label;
  final MicronutrientUnit unit;
  final double dailyValue;

  static List<Micronutrient> get featured =>
      values.take(featuredCount).toList();

  static List<Micronutrient> get extended =>
      values.skip(featuredCount).toList();

  double amountIn(FoodNutrition nutrition) {
    final vitamins = nutrition.vitamins;
    final minerals = nutrition.minerals;
    return switch (this) {
      Micronutrient.potassium => minerals.potassiumMg,
      Micronutrient.calcium => minerals.calciumMg,
      Micronutrient.iron => minerals.ironMg,
      Micronutrient.magnesium => minerals.magnesiumMg,
      Micronutrient.vitaminC => vitamins.vitaminCMg,
      Micronutrient.vitaminD => vitamins.vitaminDMcg,
      Micronutrient.vitaminA => vitamins.vitaminAMcg,
      Micronutrient.vitaminB12 => vitamins.vitaminB12Mcg,
      Micronutrient.zinc => minerals.zincMg,
      Micronutrient.folate => vitamins.vitaminB9Mcg,
      Micronutrient.vitaminE => vitamins.vitaminEMg,
      Micronutrient.vitaminK => vitamins.vitaminKMcg,
      Micronutrient.vitaminB6 => vitamins.vitaminB6Mg,
      Micronutrient.thiamin => vitamins.vitaminB1Mg,
      Micronutrient.riboflavin => vitamins.vitaminB2Mg,
      Micronutrient.niacin => vitamins.vitaminB3Mg,
      Micronutrient.pantothenicAcid => vitamins.vitaminB5Mg,
      Micronutrient.biotin => vitamins.vitaminB7Mcg,
      Micronutrient.choline => vitamins.cholineMg,
      Micronutrient.phosphorus => minerals.phosphorusMg,
      Micronutrient.copper => minerals.copperMg,
      Micronutrient.manganese => minerals.manganeseMg,
      Micronutrient.selenium => minerals.seleniumMcg,
      Micronutrient.iodine => minerals.iodineMcg,
    };
  }
}

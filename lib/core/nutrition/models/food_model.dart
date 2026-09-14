double _toDouble(Object? value) => (value as num).toDouble();

enum FoodSource { scan, manual }

class MacroNutrients {
  const MacroNutrients({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.addedSugarG,
    required this.saturatedFatG,
    required this.transFatG,
    required this.monounsaturatedFatG,
    required this.polyunsaturatedFatG,
    required this.cholesterolMg,
    required this.waterMl,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double addedSugarG;
  final double saturatedFatG;
  final double transFatG;
  final double monounsaturatedFatG;
  final double polyunsaturatedFatG;
  final double cholesterolMg;
  final double waterMl;

  factory MacroNutrients.fromJson(Map<String, dynamic> json) => MacroNutrients(
    calories: _toDouble(json['calories']),
    proteinG: _toDouble(json['proteinG']),
    carbsG: _toDouble(json['carbsG']),
    fatG: _toDouble(json['fatG']),
    fiberG: _toDouble(json['fiberG']),
    sugarG: _toDouble(json['sugarG']),
    addedSugarG: _toDouble(json['addedSugarG']),
    saturatedFatG: _toDouble(json['saturatedFatG']),
    transFatG: _toDouble(json['transFatG']),
    monounsaturatedFatG: _toDouble(json['monounsaturatedFatG']),
    polyunsaturatedFatG: _toDouble(json['polyunsaturatedFatG']),
    cholesterolMg: _toDouble(json['cholesterolMg']),
    waterMl: _toDouble(json['waterMl'] ?? 0),
  );

  MacroNutrients copyWith({
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? sugarG,
    double? waterMl,
  }) => MacroNutrients(
    calories: calories ?? this.calories,
    proteinG: proteinG ?? this.proteinG,
    carbsG: carbsG ?? this.carbsG,
    fatG: fatG ?? this.fatG,
    fiberG: fiberG ?? this.fiberG,
    sugarG: sugarG ?? this.sugarG,
    addedSugarG: addedSugarG,
    saturatedFatG: saturatedFatG,
    transFatG: transFatG,
    monounsaturatedFatG: monounsaturatedFatG,
    polyunsaturatedFatG: polyunsaturatedFatG,
    cholesterolMg: cholesterolMg,
    waterMl: waterMl ?? this.waterMl,
  );

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'fiberG': fiberG,
    'sugarG': sugarG,
    'addedSugarG': addedSugarG,
    'saturatedFatG': saturatedFatG,
    'transFatG': transFatG,
    'monounsaturatedFatG': monounsaturatedFatG,
    'polyunsaturatedFatG': polyunsaturatedFatG,
    'cholesterolMg': cholesterolMg,
    'waterMl': waterMl,
  };
}

class Vitamins {
  const Vitamins({
    required this.vitaminAMcg,
    required this.vitaminB1Mg,
    required this.vitaminB2Mg,
    required this.vitaminB3Mg,
    required this.vitaminB5Mg,
    required this.vitaminB6Mg,
    required this.vitaminB7Mcg,
    required this.vitaminB9Mcg,
    required this.vitaminB12Mcg,
    required this.vitaminCMg,
    required this.vitaminDMcg,
    required this.vitaminEMg,
    required this.vitaminKMcg,
    required this.cholineMg,
  });

  static const zero = Vitamins(
    vitaminAMcg: 0,
    vitaminB1Mg: 0,
    vitaminB2Mg: 0,
    vitaminB3Mg: 0,
    vitaminB5Mg: 0,
    vitaminB6Mg: 0,
    vitaminB7Mcg: 0,
    vitaminB9Mcg: 0,
    vitaminB12Mcg: 0,
    vitaminCMg: 0,
    vitaminDMcg: 0,
    vitaminEMg: 0,
    vitaminKMcg: 0,
    cholineMg: 0,
  );

  final double vitaminAMcg;
  final double vitaminB1Mg;
  final double vitaminB2Mg;
  final double vitaminB3Mg;
  final double vitaminB5Mg;
  final double vitaminB6Mg;
  final double vitaminB7Mcg;
  final double vitaminB9Mcg;
  final double vitaminB12Mcg;
  final double vitaminCMg;
  final double vitaminDMcg;
  final double vitaminEMg;
  final double vitaminKMcg;
  final double cholineMg;

  factory Vitamins.fromJson(Map<String, dynamic> json) => Vitamins(
    vitaminAMcg: _toDouble(json['vitaminAMcg']),
    vitaminB1Mg: _toDouble(json['vitaminB1Mg']),
    vitaminB2Mg: _toDouble(json['vitaminB2Mg']),
    vitaminB3Mg: _toDouble(json['vitaminB3Mg']),
    vitaminB5Mg: _toDouble(json['vitaminB5Mg']),
    vitaminB6Mg: _toDouble(json['vitaminB6Mg']),
    vitaminB7Mcg: _toDouble(json['vitaminB7Mcg']),
    vitaminB9Mcg: _toDouble(json['vitaminB9Mcg']),
    vitaminB12Mcg: _toDouble(json['vitaminB12Mcg']),
    vitaminCMg: _toDouble(json['vitaminCMg']),
    vitaminDMcg: _toDouble(json['vitaminDMcg']),
    vitaminEMg: _toDouble(json['vitaminEMg']),
    vitaminKMcg: _toDouble(json['vitaminKMcg']),
    cholineMg: _toDouble(json['cholineMg']),
  );

  Map<String, dynamic> toJson() => {
    'vitaminAMcg': vitaminAMcg,
    'vitaminB1Mg': vitaminB1Mg,
    'vitaminB2Mg': vitaminB2Mg,
    'vitaminB3Mg': vitaminB3Mg,
    'vitaminB5Mg': vitaminB5Mg,
    'vitaminB6Mg': vitaminB6Mg,
    'vitaminB7Mcg': vitaminB7Mcg,
    'vitaminB9Mcg': vitaminB9Mcg,
    'vitaminB12Mcg': vitaminB12Mcg,
    'vitaminCMg': vitaminCMg,
    'vitaminDMcg': vitaminDMcg,
    'vitaminEMg': vitaminEMg,
    'vitaminKMcg': vitaminKMcg,
    'cholineMg': cholineMg,
  };
}

class Minerals {
  const Minerals({
    required this.calciumMg,
    required this.ironMg,
    required this.magnesiumMg,
    required this.phosphorusMg,
    required this.potassiumMg,
    required this.sodiumMg,
    required this.zincMg,
    required this.copperMg,
    required this.manganeseMg,
    required this.seleniumMcg,
    required this.iodineMcg,
  });

  static const zero = Minerals(
    calciumMg: 0,
    ironMg: 0,
    magnesiumMg: 0,
    phosphorusMg: 0,
    potassiumMg: 0,
    sodiumMg: 0,
    zincMg: 0,
    copperMg: 0,
    manganeseMg: 0,
    seleniumMcg: 0,
    iodineMcg: 0,
  );

  final double calciumMg;
  final double ironMg;
  final double magnesiumMg;
  final double phosphorusMg;
  final double potassiumMg;
  final double sodiumMg;
  final double zincMg;
  final double copperMg;
  final double manganeseMg;
  final double seleniumMcg;
  final double iodineMcg;

  factory Minerals.fromJson(Map<String, dynamic> json) => Minerals(
    calciumMg: _toDouble(json['calciumMg']),
    ironMg: _toDouble(json['ironMg']),
    magnesiumMg: _toDouble(json['magnesiumMg']),
    phosphorusMg: _toDouble(json['phosphorusMg']),
    potassiumMg: _toDouble(json['potassiumMg']),
    sodiumMg: _toDouble(json['sodiumMg']),
    zincMg: _toDouble(json['zincMg']),
    copperMg: _toDouble(json['copperMg']),
    manganeseMg: _toDouble(json['manganeseMg']),
    seleniumMcg: _toDouble(json['seleniumMcg']),
    iodineMcg: _toDouble(json['iodineMcg']),
  );

  Minerals copyWith({double? sodiumMg}) => Minerals(
    calciumMg: calciumMg,
    ironMg: ironMg,
    magnesiumMg: magnesiumMg,
    phosphorusMg: phosphorusMg,
    potassiumMg: potassiumMg,
    sodiumMg: sodiumMg ?? this.sodiumMg,
    zincMg: zincMg,
    copperMg: copperMg,
    manganeseMg: manganeseMg,
    seleniumMcg: seleniumMcg,
    iodineMcg: iodineMcg,
  );

  Map<String, dynamic> toJson() => {
    'calciumMg': calciumMg,
    'ironMg': ironMg,
    'magnesiumMg': magnesiumMg,
    'phosphorusMg': phosphorusMg,
    'potassiumMg': potassiumMg,
    'sodiumMg': sodiumMg,
    'zincMg': zincMg,
    'copperMg': copperMg,
    'manganeseMg': manganeseMg,
    'seleniumMcg': seleniumMcg,
    'iodineMcg': iodineMcg,
  };
}

class FoodNutrition {
  const FoodNutrition({
    required this.macros,
    required this.vitamins,
    required this.minerals,
  });

  final MacroNutrients macros;
  final Vitamins vitamins;
  final Minerals minerals;

  factory FoodNutrition.fromJson(Map<String, dynamic> json) => FoodNutrition(
    macros: MacroNutrients.fromJson(json['macros'] as Map<String, dynamic>),
    vitamins: Vitamins.fromJson(json['vitamins'] as Map<String, dynamic>),
    minerals: Minerals.fromJson(json['minerals'] as Map<String, dynamic>),
  );

  FoodNutrition copyWith({MacroNutrients? macros, Minerals? minerals}) =>
      FoodNutrition(
        macros: macros ?? this.macros,
        vitamins: vitamins,
        minerals: minerals ?? this.minerals,
      );

  Map<String, dynamic> toJson() => {
    'macros': macros.toJson(),
    'vitamins': vitamins.toJson(),
    'minerals': minerals.toJson(),
  };
}

class FoodIngredient {
  const FoodIngredient({
    required this.name,
    required this.quantity,
    required this.weightG,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String name;
  final String quantity;
  final double weightG;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory FoodIngredient.fromJson(Map<String, dynamic> json) => FoodIngredient(
    name: json['name'] as String,
    quantity: json['quantity'] as String,
    weightG: _toDouble(json['weightG']),
    calories: _toDouble(json['calories']),
    proteinG: _toDouble(json['proteinG']),
    carbsG: _toDouble(json['carbsG']),
    fatG: _toDouble(json['fatG']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'weightG': weightG,
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };
}

class FoodModel {
  const FoodModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.servingDescription,
    required this.servingWeightG,
    required this.confidence,
    required this.healthScore,
    required this.ingredients,
    required this.nutrition,
    required this.source,
    this.aiModel,
    this.promptVersion,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final String servingDescription;
  final double servingWeightG;
  final double confidence;
  final int healthScore;
  final List<FoodIngredient> ingredients;
  final FoodNutrition nutrition;
  final FoodSource source;
  final String? aiModel;
  final String? promptVersion;
  final DateTime createdAt;

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    servingDescription: json['servingDescription'] as String,
    servingWeightG: _toDouble(json['servingWeightG']),
    confidence: _toDouble(json['confidence']),
    healthScore: (json['healthScore'] as num).toInt(),
    ingredients: (json['ingredients'] as List<dynamic>)
        .map((item) => FoodIngredient.fromJson(item as Map<String, dynamic>))
        .toList(),
    nutrition: FoodNutrition.fromJson(
      json['nutrition'] as Map<String, dynamic>,
    ),
    source: FoodSource.values.byName(json['source'] as String),
    aiModel: json['aiModel'] as String?,
    promptVersion: json['promptVersion'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  FoodModel copyWith({
    String? id,
    String? name,
    FoodNutrition? nutrition,
    DateTime? createdAt,
  }) => FoodModel(
    id: id ?? this.id,
    userId: userId,
    name: name ?? this.name,
    description: description,
    servingDescription: servingDescription,
    servingWeightG: servingWeightG,
    confidence: confidence,
    healthScore: healthScore,
    ingredients: ingredients,
    nutrition: nutrition ?? this.nutrition,
    source: source,
    aiModel: aiModel,
    promptVersion: promptVersion,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'servingDescription': servingDescription,
    'servingWeightG': servingWeightG,
    'confidence': confidence,
    'healthScore': healthScore,
    'ingredients': ingredients.map((item) => item.toJson()).toList(),
    'nutrition': nutrition.toJson(),
    'source': source.name,
    'aiModel': aiModel,
    'promptVersion': promptVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

import 'package:flutter/material.dart';

import 'package:floww/core/nutrition/models/food_catalog.dart';
import 'package:floww/core/nutrition/models/food_model.dart';

class WaveDailyBrief {
  const WaveDailyBrief({
    required this.greeting,
    required this.userName,
    required this.flowScore,
    required this.modeLabel,
    required this.workoutTitle,
    required this.workoutDetail,
    required this.calories,
    required this.proteinDetail,
    required this.focusItems,
  });

  final String greeting;
  final String userName;
  final int flowScore;
  final String modeLabel;
  final String workoutTitle;
  final String workoutDetail;
  final int calories;
  final String proteinDetail;
  final List<String> focusItems;
}

enum WavePlanAction { startWorkout, logMeal, logWater }

class WavePlanItem {
  const WavePlanItem({
    required this.emoji,
    required this.label,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.action,
  });

  final String emoji;
  final String label;
  final String title;
  final String detail;
  final String actionLabel;
  final WavePlanAction action;
}

class WaveInjurySwap {
  const WaveInjurySwap({
    required this.title,
    required this.removing,
    required this.adding,
    required this.rationale,
    this.removingEntryId,
    this.addingExerciseId,
  });

  final String title;
  final String removing;
  final String adding;
  final String rationale;
  final String? removingEntryId;
  final String? addingExerciseId;
}

class WaveScoreFactor {
  const WaveScoreFactor({
    required this.icon,
    required this.label,
    required this.value,
    required this.isLow,
  });

  final IconData icon;
  final String label;
  final int value;
  final bool isLow;

  double get fraction => value / 100;
}

class WaveScoreReport {
  const WaveScoreReport({
    required this.score,
    required this.potentialLabel,
    required this.factors,
  });

  final int score;
  final String potentialLabel;
  final List<WaveScoreFactor> factors;

  int get lowFactorCount =>
      factors.where((factor) => factor.isLow).length;

  String get summary =>
      '$lowFactorCount factors pulling your score down';
}

enum WaveFeeling {
  great,
  normal,
  fatigued,
  sore;

  String get emoji => switch (this) {
    WaveFeeling.great => '😊',
    WaveFeeling.normal => '😐',
    WaveFeeling.fatigued => '😓',
    WaveFeeling.sore => '🤕',
  };

  String get label => switch (this) {
    WaveFeeling.great => 'Great',
    WaveFeeling.normal => 'Normal',
    WaveFeeling.fatigued => 'Fatigued',
    WaveFeeling.sore => 'Sore',
  };

  String get response => switch (this) {
    WaveFeeling.great => "Let's keep the momentum! 🔥",
    WaveFeeling.normal => 'Steady work. Recovery stays on plan.',
    WaveFeeling.fatigued => "Noted — I'll lighten tomorrow's load.",
    WaveFeeling.sore => "I'll add extra recovery before your next session.",
  };
}

enum WaveMealSlot {
  breakfast,
  lunch,
  dinner,
  snack;

  String get emoji => switch (this) {
    WaveMealSlot.breakfast => '🌅',
    WaveMealSlot.lunch => '☀️',
    WaveMealSlot.dinner => '🌙',
    WaveMealSlot.snack => '🍎',
  };

  String get label => switch (this) {
    WaveMealSlot.breakfast => 'Breakfast',
    WaveMealSlot.lunch => 'Lunch',
    WaveMealSlot.dinner => 'Dinner',
    WaveMealSlot.snack => 'Snack',
  };
}

class WaveQuickFood {
  const WaveQuickFood({
    required this.emoji,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.catalog,
    this.template,
  });

  factory WaveQuickFood.fromCatalog(CatalogFood food) => WaveQuickFood(
    emoji: WaveFoodEmoji.of(food.name),
    name: food.name,
    calories: food.calories.round(),
    protein: food.proteinG.round(),
    carbs: food.carbsG.round(),
    fat: food.fatG.round(),
    catalog: food,
  );

  factory WaveQuickFood.fromLoggedFood(FoodModel food) {
    final macros = food.nutrition.macros;
    return WaveQuickFood(
      emoji: WaveFoodEmoji.of(food.name),
      name: food.name,
      calories: macros.calories.round(),
      protein: macros.proteinG.round(),
      carbs: macros.carbsG.round(),
      fat: macros.fatG.round(),
      template: food,
    );
  }

  final String emoji;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final CatalogFood? catalog;
  final FoodModel? template;
}

class WaveFoodEmoji {
  WaveFoodEmoji._();

  static const String fallback = '🍽️';

  static const Map<String, String> _byKeyword = {
    'rice': '🍚',
    'chicken': '🍗',
    'egg': '🥚',
    'lentil': '🫘',
    'dal': '🫘',
    'bean': '🫘',
    'roti': '🫓',
    'chapati': '🫓',
    'bread': '🍞',
    'paneer': '🧀',
    'cheese': '🧀',
    'yogurt': '🥛',
    'milk': '🥛',
    'banana': '🍌',
    'apple': '🍎',
    'avocado': '🥑',
    'almond': '🌰',
    'peanut': '🥜',
    'oat': '🥣',
    'salmon': '🐟',
    'tuna': '🐟',
    'fish': '🐟',
    'beef': '🥩',
    'steak': '🥩',
    'broccoli': '🥦',
    'green': '🥬',
    'potato': '🍠',
    'quinoa': '🌾',
    'tofu': '🧊',
    'pasta': '🍝',
    'juice': '🧃',
    'oil': '🫒',
    'protein': '🥤',
    'chocolate': '🍫',
  };

  static String of(String name) {
    final normalized = name.toLowerCase();
    for (final entry in _byKeyword.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }
    return fallback;
  }
}

class WaveMealTotals {
  const WaveMealTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.itemCount,
  });

  static const empty = WaveMealTotals(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    itemCount: 0,
  );

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int itemCount;

  bool get isEmpty => itemCount == 0;

  String get itemCountLabel => itemCount == 1 ? '1 item' : '$itemCount items';

  String get logLabel => itemCount == 1 ? 'Log 1 Item' : 'Log $itemCount Items';
}

class WaveDietMeal {
  const WaveDietMeal({
    required this.emoji,
    required this.name,
    required this.calories,
  });

  final String emoji;
  final String name;
  final int calories;
}

class WaveDietPlan {
  const WaveDietPlan({
    required this.title,
    required this.description,
    required this.meals,
  });

  final String title;
  final String description;
  final List<WaveDietMeal> meals;

  int get totalCalories =>
      meals.fold(0, (total, meal) => total + meal.calories);
}

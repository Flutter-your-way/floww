import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/models/weekly_metric.dart';

extension MacroNutrientStyle on MacroNutrient {
  Color colorOf(BuildContext context) => switch (this) {
    MacroNutrient.protein => context.colors.proteinAccent,
    MacroNutrient.carbs => context.colors.carbsAccent,
    MacroNutrient.fats => context.colors.fatAccent,
  };

  IconData get icon => switch (this) {
    MacroNutrient.protein => Icons.egg_alt_outlined,
    MacroNutrient.carbs => Icons.grass_rounded,
    MacroNutrient.fats => Icons.water_drop_outlined,
  };
}

extension MealTypeStyle on MealType {
  IconData get icon => switch (this) {
    MealType.breakfast => Icons.wb_twilight_rounded,
    MealType.lunch => Icons.wb_sunny_rounded,
    MealType.dinner => Icons.nightlight_round,
    MealType.snacks => Icons.cookie_outlined,
  };

  Color colorOf(BuildContext context) => switch (this) {
    MealType.breakfast || MealType.lunch => context.colors.accentOrange,
    MealType.dinner || MealType.snacks => context.colors.textPrimary,
  };
}

extension WeeklyMetricStyle on WeeklyMetric {
  Color colorOf(BuildContext context) => switch (this) {
    WeeklyMetric.calories => context.colors.primary,
    WeeklyMetric.protein => context.colors.primary,
    WeeklyMetric.fiber => context.colors.fiberAccent,
  };
}

extension DayLogStatusStyle on DayLogStatus {
  Color colorOf(BuildContext context) => switch (this) {
    DayLogStatus.full => context.colors.primary,
    DayLogStatus.partial => context.colors.accentOrangeMuted,
    DayLogStatus.none => context.colors.backgroundElevated,
  };

  String get label => switch (this) {
    DayLogStatus.full => 'Full day logged',
    DayLogStatus.partial => 'Partial',
    DayLogStatus.none => 'Not logged',
  };
}

extension MicronutrientKindStyle on MicronutrientKind {
  IconData get icon => switch (this) {
    MicronutrientKind.water => Icons.water_drop_rounded,
    MicronutrientKind.fiber => Icons.eco_rounded,
    MicronutrientKind.sugar => Icons.icecream_outlined,
    MicronutrientKind.sodium => Icons.grain_rounded,
  };
}

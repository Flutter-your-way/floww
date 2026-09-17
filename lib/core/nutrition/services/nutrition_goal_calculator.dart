import 'dart:math' as math;

import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/profile/models/profile_account.dart';

class NutritionGoalCalculator {
  const NutritionGoalCalculator();

  static const int minimumCalories = 1200;
  static const int maximumCalories = 5000;

  static const double _weightFactor = 10;
  static const double _heightFactor = 6.25;
  static const double _ageFactor = 5;
  static const double _maleOffset = 5;
  static const double _femaleOffset = -161;
  static const double _neutralOffset = -78;

  static const double _sedentary = 1.2;
  static const double _lightlyActive = 1.375;
  static const double _active = 1.55;
  static const double _veryActive = 1.725;

  static const int _baselineTrainingDays = 3;
  static const double _trainingDayBonus = 0.025;
  static const double _maxTrainingBonus = 0.15;

  static const double _loseFatFactor = 0.8;
  static const double _gainMuscleFactor = 1.12;

  static const double _loseFatProteinPerKg = 2.2;
  static const double _gainMuscleProteinPerKg = 2.0;
  static const double _recompositionProteinPerKg = 2.2;
  static const double _maintenanceProteinPerKg = 1.6;

  static const double _fatCalorieShare = 0.25;
  static const double _sugarCalorieShare = 0.1;
  static const double _proteinKcalPerGram = 4;
  static const double _carbsKcalPerGram = 4;
  static const double _fatKcalPerGram = 9;

  static const double _fiberPerThousandCalories = 14;
  static const double _waterMlPerKg = 35;
  static const int _sodiumMg = 2300;

  NutritionGoal build(ProfileAccount account) {
    final weightKg = account.weightKg;
    final heightCm = account.heightCm;
    final age = account.ageYears;

    if (weightKg == null || weightKg <= 0 || heightCm == null || age == null) {
      return _withWaterTarget(NutritionGoal.defaults, account);
    }

    final bmr =
        _weightFactor * weightKg +
        _heightFactor * heightCm -
        _ageFactor * age +
        _sexOffset(account.biologicalSex);

    final maintenance = bmr * _activityMultiplier(account);
    final calories = _clampCalories(
      maintenance * _goalFactor(account.goal),
    );

    final proteinG = weightKg * _proteinPerKg(account.goal);
    final fatG = calories * _fatCalorieShare / _fatKcalPerGram;
    final carbsG = math.max(
      0.0,
      (calories - proteinG * _proteinKcalPerGram - fatG * _fatKcalPerGram) /
          _carbsKcalPerGram,
    );

    return NutritionGoal(
      calories: calories,
      proteinG: proteinG.round(),
      carbsG: carbsG.round(),
      fatsG: fatG.round(),
      fiberG: (calories / 1000 * _fiberPerThousandCalories).round(),
      sugarG: (calories * _sugarCalorieShare / _carbsKcalPerGram).round(),
      sodiumMg: _sodiumMg,
      waterMl: _waterMlOf(account, weightKg),
    );
  }

  static double _sexOffset(String? biologicalSex) => switch (biologicalSex) {
    'Male' => _maleOffset,
    'Female' => _femaleOffset,
    _ => _neutralOffset,
  };

  static double _activityMultiplier(ProfileAccount account) {
    final base = switch (account.activityLevel) {
      'Sedentary' => _sedentary,
      'Lightly Active' => _lightlyActive,
      'Active' => _active,
      'Very Active' => _veryActive,
      _ => _lightlyActive,
    };
    final days = account.trainingDaysPerWeek ?? _baselineTrainingDays;
    final extraDays = math.max(0, days - _baselineTrainingDays);
    return base + math.min(_maxTrainingBonus, extraDays * _trainingDayBonus);
  }

  static double _goalFactor(String? goal) => switch (goal) {
    'Lose Fat' => _loseFatFactor,
    'Gain Muscle' => _gainMuscleFactor,
    _ => 1,
  };

  static double _proteinPerKg(String? goal) => switch (goal) {
    'Lose Fat' => _loseFatProteinPerKg,
    'Gain Muscle' => _gainMuscleProteinPerKg,
    'Recomposition' => _recompositionProteinPerKg,
    _ => _maintenanceProteinPerKg,
  };

  static int _clampCalories(double calories) =>
      calories.round().clamp(minimumCalories, maximumCalories);

  static int _waterMlOf(ProfileAccount account, double weightKg) {
    final liters = account.waterTargetLiters;
    if (liters != null && liters > 0) return (liters * 1000).round();
    return (weightKg * _waterMlPerKg).round();
  }

  static NutritionGoal _withWaterTarget(
    NutritionGoal goal,
    ProfileAccount account,
  ) {
    final liters = account.waterTargetLiters;
    if (liters == null || liters <= 0) return goal;
    return NutritionGoal(
      calories: goal.calories,
      proteinG: goal.proteinG,
      carbsG: goal.carbsG,
      fatsG: goal.fatsG,
      fiberG: goal.fiberG,
      sugarG: goal.sugarG,
      sodiumMg: goal.sodiumMg,
      waterMl: (liters * 1000).round(),
    );
  }
}

import 'package:floww/config/entities/daily_flow_entity.dart';

class FlowScoreInputs {
  const FlowScoreInputs({
    required this.date,
    required this.workoutSets,
    required this.habitCompletion,
    required this.mealCount,
    required this.waterMl,
  });

  final DateTime date;
  final int workoutSets;
  final double habitCompletion;
  final int mealCount;
  final double waterMl;

  bool get isEmpty =>
      workoutSets == 0 &&
      habitCompletion == 0 &&
      mealCount == 0 &&
      waterMl == 0;
}

class FlowScoreCalculator {
  const FlowScoreCalculator();

  static const double workoutWeight = 0.4;
  static const double habitWeight = 0.35;
  static const double nutritionWeight = 0.25;

  static const int targetSetsPerSession = 20;
  static const int targetMealsPerDay = 3;
  static const double targetWaterMl = 2500;
  static const double mealShareOfNutrition = 0.7;
  static const double waterShareOfNutrition = 0.3;

  DailyFlowEntry scoreOf(FlowScoreInputs inputs) {
    if (inputs.isEmpty) return DailyFlowEntry.empty(inputs.date);

    return _entryOf(
      date: inputs.date,
      workout: workoutPercentOf(inputs.workoutSets),
      habit: _percent(inputs.habitCompletion),
      nutrition: _percent(
        (inputs.mealCount / targetMealsPerDay).clamp(0.0, 1.0) *
                mealShareOfNutrition +
            (inputs.waterMl / targetWaterMl).clamp(0.0, 1.0) *
                waterShareOfNutrition,
      ),
    );
  }

  DailyFlowEntry withWorkoutSets(DailyFlowEntry entry, int sets) => _entryOf(
    date: entry.date,
    workout: workoutPercentOf(sets),
    habit: entry.habitScore.toDouble(),
    nutrition: entry.nutritionScore.toDouble(),
  );

  static double workoutPercentOf(int sets) =>
      _percent(sets / targetSetsPerSession);

  DailyFlowEntry _entryOf({
    required DateTime date,
    required double workout,
    required double habit,
    required double nutrition,
  }) {
    final score =
        workout * workoutWeight +
        habit * habitWeight +
        nutrition * nutritionWeight;

    return DailyFlowEntry(
      date: date,
      score: score.round(),
      workoutScore: workout.round(),
      habitScore: habit.round(),
      nutritionScore: nutrition.round(),
    );
  }

  static double _percent(double ratio) => (ratio.clamp(0.0, 1.0)) * 100;
}

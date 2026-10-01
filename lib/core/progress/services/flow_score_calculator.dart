import 'package:floww/config/entities/daily_flow_entity.dart';

class FlowScoreInputs {
  const FlowScoreInputs({
    required this.date,
    required this.workoutSets,
    required this.habitCompletion,
    required this.mealCount,
    required this.waterMl,
    this.workoutPlannedSets = 0,
    this.readinessScore = 0,
  });

  final DateTime date;
  final int workoutSets;
  final int workoutPlannedSets;
  final double habitCompletion;
  final int mealCount;
  final double waterMl;
  final int readinessScore;

  bool get isEmpty =>
      workoutSets == 0 &&
      habitCompletion == 0 &&
      mealCount == 0 &&
      waterMl == 0;
}

class FlowScoreCalculator {
  const FlowScoreCalculator();

  static const int workoutPoints = 35;
  static const int nutritionPoints = 25;
  static const int habitPoints = 20;
  static const int recoveryPoints = 20;

  static const int targetSetsPerSession = 20;
  static const int targetMealsPerDay = 3;
  static const double targetWaterMl = 2500;
  static const double mealShareOfNutrition = 0.7;
  static const double waterShareOfNutrition = 0.3;

  DailyFlowEntry scoreOf(FlowScoreInputs inputs) => _entryOf(
    date: inputs.date,
    readiness: inputs.readinessScore,
    workout: workoutPercentOf(
      inputs.workoutSets,
      plannedSets: inputs.workoutPlannedSets,
    ),
    habit: _percent(inputs.habitCompletion),
    nutrition: _percent(
      (inputs.mealCount / targetMealsPerDay).clamp(0.0, 1.0) *
              mealShareOfNutrition +
          (inputs.waterMl / targetWaterMl).clamp(0.0, 1.0) *
              waterShareOfNutrition,
    ),
  );

  DailyFlowEntry withWorkoutSets(
    DailyFlowEntry entry,
    int sets, {
    int plannedSets = 0,
  }) => _entryOf(
    date: entry.date,
    readiness: entry.readinessScore,
    workout: workoutPercentOf(sets, plannedSets: plannedSets),
    habit: entry.habitScore.toDouble(),
    nutrition: entry.nutritionScore.toDouble(),
  );

  static int workoutTargetOf(int plannedSets) =>
      plannedSets > 0 ? plannedSets : targetSetsPerSession;

  static double workoutPercentOf(int sets, {int plannedSets = 0}) =>
      _percent(sets / workoutTargetOf(plannedSets));

  static int pointsOf(int maxPoints, num percent) =>
      (maxPoints * percent.clamp(0, 100) / 100).round();

  DailyFlowEntry _entryOf({
    required DateTime date,
    required int readiness,
    required double workout,
    required double habit,
    required double nutrition,
  }) {
    final score =
        pointsOf(workoutPoints, workout.round()) +
        pointsOf(nutritionPoints, nutrition.round()) +
        pointsOf(habitPoints, habit.round()) +
        pointsOf(recoveryPoints, readiness);

    return DailyFlowEntry(
      date: date,
      score: score.clamp(0, 100),
      readinessScore: readiness,
      workoutScore: workout.round(),
      habitScore: habit.round(),
      nutritionScore: nutrition.round(),
    );
  }

  static double _percent(double ratio) => (ratio.clamp(0.0, 1.0)) * 100;
}

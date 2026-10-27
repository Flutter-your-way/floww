import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';

class WorkoutCredit {
  const WorkoutCredit({
    required this.creditedSets,
    required this.plannedSets,
    required this.loggedSets,
  });

  static const WorkoutCredit none = WorkoutCredit(
    creditedSets: 0,
    plannedSets: 0,
    loggedSets: 0,
  );

  static WorkoutCredit ofSessions(Iterable<WorkoutSessionEntity> sessions) {
    var credit = none;
    for (final session in sessions) {
      credit += WorkoutCredit(
        creditedSets: session.creditedSets,
        plannedSets: session.plannedSets,
        loggedSets: session.totalSets,
      );
    }
    return credit;
  }

  static WorkoutCredit ofLogs(Iterable<WorkoutSessionLog> sessions) {
    var credit = none;
    for (final session in sessions) {
      credit += WorkoutCredit(
        creditedSets: session.creditedSets,
        plannedSets: session.plannedSets,
        loggedSets: session.totalSets,
      );
    }
    return credit;
  }

  final double creditedSets;
  final int plannedSets;
  final int loggedSets;

  bool get hasPlan => plannedSets > 0;

  int get target =>
      hasPlan ? plannedSets : FlowScoreCalculator.targetSetsPerSession;

  int get done => hasPlan ? creditedSets.floor() : loggedSets;

  double get ratio => hasPlan
      ? creditedSets / plannedSets
      : loggedSets / FlowScoreCalculator.targetSetsPerSession;

  WorkoutCredit operator +(WorkoutCredit other) => WorkoutCredit(
    creditedSets: creditedSets + other.creditedSets,
    plannedSets: plannedSets + other.plannedSets,
    loggedSets: loggedSets + other.loggedSets,
  );
}

class FlowScoreInputs {
  const FlowScoreInputs({
    required this.date,
    required this.workout,
    required this.habitCompletion,
    required this.mealCount,
    required this.waterMl,
    this.readinessScore = 0,
  });

  final DateTime date;
  final WorkoutCredit workout;
  final double habitCompletion;
  final int mealCount;
  final double waterMl;
  final int readinessScore;
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
    workout: workoutPercentOf(inputs.workout),
    habit: _percent(inputs.habitCompletion),
    nutrition: _percent(
      (inputs.mealCount / targetMealsPerDay).clamp(0.0, 1.0) *
              mealShareOfNutrition +
          (inputs.waterMl / targetWaterMl).clamp(0.0, 1.0) *
              waterShareOfNutrition,
    ),
  );

  DailyFlowEntry withWorkout(DailyFlowEntry entry, WorkoutCredit workout) =>
      _entryOf(
        date: entry.date,
        readiness: entry.readinessScore,
        workout: workoutPercentOf(workout),
        habit: entry.habitScore.toDouble(),
        nutrition: entry.nutritionScore.toDouble(),
      );

  static double workoutPercentOf(WorkoutCredit workout) =>
      _percent(workout.ratio);

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

  static double _percent(double ratio) =>
      ratio.isFinite ? ratio.clamp(0.0, 1.0) * 100 : 0;
}

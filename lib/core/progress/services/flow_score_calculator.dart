import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';

class WorkoutCredit {
  const WorkoutCredit({
    required this.creditedSets,
    required this.plannedSets,
    required this.loggedSets,
    required this.sessionRatio,
    this.isRestDay = false,
  });

  factory WorkoutCredit.session({
    required double creditedSets,
    required int plannedSets,
    required int loggedSets,
  }) => WorkoutCredit(
    creditedSets: creditedSets,
    plannedSets: plannedSets,
    loggedSets: loggedSets,
    sessionRatio: plannedSets > 0
        ? creditedSets / plannedSets
        : loggedSets / FlowScoreCalculator.targetSetsPerSession,
  );

  static const WorkoutCredit none = WorkoutCredit(
    creditedSets: 0,
    plannedSets: 0,
    loggedSets: 0,
    sessionRatio: 0,
  );

  static const WorkoutCredit restDay = WorkoutCredit(
    creditedSets: 0,
    plannedSets: 0,
    loggedSets: 0,
    sessionRatio: 0,
    isRestDay: true,
  );

  static WorkoutCredit ofSessions(Iterable<WorkoutSessionEntity> sessions) {
    var credit = none;
    for (final session in sessions) {
      credit += WorkoutCredit.session(
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
      credit += WorkoutCredit.session(
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
  final double sessionRatio;
  final bool isRestDay;

  bool get hasPlan => plannedSets > 0;

  int get target =>
      hasPlan ? plannedSets : FlowScoreCalculator.targetSetsPerSession;

  double get done => hasPlan ? creditedSets : loggedSets.toDouble();

  double get ratio => sessionRatio + (isRestDay ? 1 : 0);

  WorkoutCredit operator +(WorkoutCredit other) => WorkoutCredit(
    creditedSets: creditedSets + other.creditedSets,
    plannedSets: plannedSets + other.plannedSets,
    loggedSets: loggedSets + other.loggedSets,
    sessionRatio: sessionRatio + other.sessionRatio,
    isRestDay: isRestDay || other.isRestDay,
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
    this.habitEngaged = false,
  });

  final DateTime date;
  final WorkoutCredit workout;
  final double habitCompletion;
  final int mealCount;
  final double waterMl;
  final int readinessScore;
  final bool habitEngaged;
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
    trained: _percent(inputs.workout.sessionRatio),
    habitEngaged: inputs.habitEngaged,
    isRestDay: inputs.workout.isRestDay,
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
        trained: _percent(workout.sessionRatio),
        habitEngaged: entry.isActive ?? entry.habitScore > 0,
        isRestDay: workout.isRestDay,
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
    required double trained,
    required bool habitEngaged,
    required bool isRestDay,
    required double habit,
    required double nutrition,
  }) {
    final isActive =
        trained.round() > 0 || nutrition.round() > 0 || habitEngaged;
    final habitScore = isActive ? habit.round() : 0;
    final score =
        pointsOf(workoutPoints, workout.round()) +
        pointsOf(nutritionPoints, nutrition.round()) +
        pointsOf(habitPoints, habitScore) +
        pointsOf(recoveryPoints, readiness);

    return DailyFlowEntry(
      date: date,
      score: score.clamp(0, 100),
      readinessScore: readiness,
      workoutScore: workout.round(),
      habitScore: habitScore,
      nutritionScore: nutrition.round(),
      isActive: isActive,
      isRestDay: isRestDay,
    );
  }

  static double _percent(double ratio) =>
      ratio.isFinite ? ratio.clamp(0.0, 1.0) * 100 : 0;
}

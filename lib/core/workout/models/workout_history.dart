import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';

enum WorkoutDayOutcome { completed, partial, missed, rest, pending }

enum MissedRecovery { catchUp, covered, prioritize, letGo }

class MissedWorkoutInsight {
  const MissedWorkoutInsight({
    required this.recovery,
    required this.muscles,
    this.coveredOn,
    this.keyExercise,
  });

  final MissedRecovery recovery;
  final List<String> muscles;
  final DateTime? coveredOn;
  final String? keyExercise;
}

class WorkoutHistoryDay {
  const WorkoutHistoryDay({
    required this.date,
    required this.outcome,
    this.plan,
    this.sessions = const [],
    this.insight,
  });

  final DateTime date;
  final WorkoutDayOutcome outcome;
  final WorkoutPlanEntity? plan;
  final List<WorkoutSessionEntity> sessions;
  final MissedWorkoutInsight? insight;

  bool get isPlanned => plan != null;
}

class WorkoutConsistency {
  const WorkoutConsistency({
    required this.planned,
    required this.completed,
    required this.workouts,
    required this.missed,
    required this.streak,
    required this.missedInRow,
    this.mostMissedWeekday,
    this.mostMissedCount = 0,
  });

  final int planned;
  final int completed;
  final int workouts;
  final int missed;
  final int streak;
  final int missedInRow;
  final int? mostMissedWeekday;
  final int mostMissedCount;

  double? get adherence => planned == 0 ? null : completed / planned;
}

class WorkoutHistoryAnalysis {
  const WorkoutHistoryAnalysis({
    required this.days,
    required this.consistencyDays,
    required this.consistency,
  });

  final List<WorkoutHistoryDay> days;
  final List<WorkoutHistoryDay> consistencyDays;
  final WorkoutConsistency consistency;
}

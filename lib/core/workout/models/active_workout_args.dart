import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';

class ActiveWorkoutArgs {
  const ActiveWorkoutArgs({
    required this.date,
    this.plan,
    this.history,
    this.session,
  });

  final DateTime date;
  final WorkoutPlanEntity? plan;
  final List<WorkoutSessionEntity>? history;
  final WorkoutSessionEntity? session;
}

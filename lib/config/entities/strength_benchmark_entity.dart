import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';

class StrengthBenchmark {
  const StrengthBenchmark({
    required this.id,
    required this.muscle,
    required this.exercise,
    required this.weightKg,
    required this.reps,
    required this.loggedAt,
  });

  factory StrengthBenchmark.fromJson(Map<String, dynamic> json) =>
      StrengthBenchmark(
        id: json['id'] as String,
        muscle: json['muscle'] as String,
        exercise: json['exercise'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        reps: (json['reps'] as num).toInt(),
        loggedAt: DateTime.parse(json['loggedAt'] as String).toLocal(),
      );

  final String id;
  final String muscle;
  final String exercise;
  final double weightKg;
  final int reps;
  final DateTime loggedAt;

  double get oneRepMaxKg =>
      WorkoutEntryEntity.estimatedOneRepMax(weightKg, reps);

  Map<String, dynamic> toJson() => {
    'id': id,
    'muscle': muscle,
    'exercise': exercise,
    'weightKg': weightKg,
    'reps': reps,
    'loggedAt': AppDateUtils.isoKey(loggedAt),
  };
}

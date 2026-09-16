import 'package:floww/config/utils/dates/app_date_utils.dart';

class WorkoutSessionLog {
  const WorkoutSessionLog({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.completedAt,
    required this.durationSeconds,
    required this.exerciseCount,
    required this.totalSets,
    required this.volumeKg,
  });

  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionLog(
        id: json['id'] as String,
        workoutId: json['workoutId'] as String,
        name: json['name'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String).toLocal(),
        durationSeconds: (json['durationSeconds'] as num).toInt(),
        exerciseCount: (json['exerciseCount'] as num).toInt(),
        totalSets: (json['totalSets'] as num).toInt(),
        volumeKg: (json['volumeKg'] as num).toDouble(),
      );

  final String id;
  final String workoutId;
  final String name;
  final DateTime completedAt;
  final int durationSeconds;
  final int exerciseCount;
  final int totalSets;
  final double volumeKg;

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'name': name,
    'completedAt': AppDateUtils.isoKey(completedAt),
    'durationSeconds': durationSeconds,
    'exerciseCount': exerciseCount,
    'totalSets': totalSets,
    'volumeKg': volumeKg,
  };
}

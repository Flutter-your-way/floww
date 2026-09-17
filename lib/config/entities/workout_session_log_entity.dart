import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';

class WorkoutSessionLog {
  WorkoutSessionLog({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.completedAt,
    required this.durationSeconds,
    required this.exerciseCount,
    required this.totalSets,
    required this.volumeKg,
    DateTime? date,
    this.status = WorkoutSessionStatus.completed,
  }) : date = date ?? AppDateUtils.dateOnly(completedAt);

  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) {
    final completedAt = DateTime.parse(json['completedAt'] as String).toLocal();
    final date = json['date'] as String?;
    return WorkoutSessionLog(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      name: json['name'] as String,
      completedAt: completedAt,
      date: date == null ? null : DateTime.parse(date),
      status: _statusOf(json['status'] as String?),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      volumeKg: (json['volumeKg'] as num).toDouble(),
    );
  }

  final String id;
  final String workoutId;
  final String name;
  final DateTime completedAt;
  final DateTime date;
  final WorkoutSessionStatus status;
  final int durationSeconds;
  final int exerciseCount;
  final int totalSets;
  final double volumeKg;

  bool get isCompleted => status == WorkoutSessionStatus.completed;

  static WorkoutSessionStatus _statusOf(String? value) =>
      WorkoutSessionStatus.values
          .where((status) => status.name == value)
          .firstOrNull ??
      WorkoutSessionStatus.completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'name': name,
    'date': AppDateUtils.dateKey(date),
    'status': status.name,
    'completedAt': AppDateUtils.isoKey(completedAt),
    'durationSeconds': durationSeconds,
    'exerciseCount': exerciseCount,
    'totalSets': totalSets,
    'volumeKg': volumeKg,
  };
}

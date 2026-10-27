import 'package:floww/config/entities/workout_plan_entity.dart';
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
    this.plannedSets = 0,
    double? creditedSets,
    DateTime? date,
    this.status = WorkoutSessionStatus.completed,
  }) : date = date ?? AppDateUtils.dateOnly(completedAt),
       creditedSets =
           creditedSets ??
           (plannedSets > 0 && totalSets > plannedSets ? plannedSets : totalSets)
               .toDouble();

  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) {
    final completedAt = DateTime.parse(json['completedAt'] as String).toLocal();
    final date = json['date'] as String?;
    final totalSets = (json['totalSets'] as num).toInt();
    final plannedSets = _plannedSetsOf(json);
    return WorkoutSessionLog(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      name: json['name'] as String,
      completedAt: completedAt,
      date: date == null ? null : DateTime.parse(date),
      status: _statusOf(json['status'] as String?),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      totalSets: totalSets,
      volumeKg: (json['volumeKg'] as num).toDouble(),
      plannedSets: plannedSets,
      creditedSets: _creditedSetsOf(json),
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
  final int plannedSets;
  final double creditedSets;

  bool get isCompleted => status == WorkoutSessionStatus.completed;

  static int _plannedSetsOf(Map<String, dynamic> json) {
    final stored = (json['plannedSets'] as num? ?? 0).toInt();
    if (stored > 0) return stored;
    var total = 0;
    for (final entry in json['exercises'] as List? ?? const []) {
      if (entry is Map) total += (entry['targetSets'] as num? ?? 0).toInt();
    }
    return total;
  }

  static double? _creditedSetsOf(Map<String, dynamic> json) {
    final entries = WorkoutPlanEntity.entriesOf(json['exercises']);
    if (entries.isNotEmpty) return WorkoutPlanEntity.creditedSetsOf(entries);
    return (json['creditedSets'] as num?)?.toDouble();
  }

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
    'plannedSets': plannedSets,
    'creditedSets': creditedSets,
    'volumeKg': volumeKg,
  };
}

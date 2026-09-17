import 'package:floww/config/utils/dates/app_date_utils.dart';

class HealthDayLog {
  const HealthDayLog({
    required this.date,
    required this.steps,
    required this.activeCaloriesKcal,
    required this.sleepMinutes,
    required this.workoutCount,
    required this.syncedAt,
    this.restingHeartRate,
    this.hrvMs,
  });

  factory HealthDayLog.fromJson(Map<String, dynamic> json) => HealthDayLog(
    date: DateTime.parse(json['date'] as String),
    steps: (json['steps'] as num? ?? 0).toInt(),
    activeCaloriesKcal: (json['activeCaloriesKcal'] as num? ?? 0).toInt(),
    sleepMinutes: (json['sleepMinutes'] as num? ?? 0).toInt(),
    workoutCount: (json['workoutCount'] as num? ?? 0).toInt(),
    syncedAt: DateTime.parse(json['syncedAt'] as String).toLocal(),
    restingHeartRate: (json['restingHeartRate'] as num?)?.toInt(),
    hrvMs: (json['hrvMs'] as num?)?.toDouble(),
  );

  final DateTime date;
  final int steps;
  final int activeCaloriesKcal;
  final int sleepMinutes;
  final int workoutCount;
  final DateTime syncedAt;
  final int? restingHeartRate;
  final double? hrvMs;

  bool get hasData =>
      steps > 0 ||
      activeCaloriesKcal > 0 ||
      sleepMinutes > 0 ||
      workoutCount > 0 ||
      restingHeartRate != null ||
      hrvMs != null;

  Map<String, dynamic> toJson() => {
    'date': AppDateUtils.dateKey(date),
    'steps': steps,
    'activeCaloriesKcal': activeCaloriesKcal,
    'sleepMinutes': sleepMinutes,
    'workoutCount': workoutCount,
    'syncedAt': AppDateUtils.isoKey(syncedAt),
    if (restingHeartRate != null) 'restingHeartRate': restingHeartRate,
    if (hrvMs != null) 'hrvMs': hrvMs,
  };
}

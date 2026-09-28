import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/health/models/health_snapshot.dart';
import 'package:floww/core/health/services/health_service.dart';
import 'package:floww/core/workout/models/workout_completion.dart';

enum ReadinessLevel { low, normal, high }

class WorkoutReadiness {
  const WorkoutReadiness({required this.level, this.reasons = const []});

  static const WorkoutReadiness normal = WorkoutReadiness(
    level: ReadinessLevel.normal,
  );

  final ReadinessLevel level;
  final List<String> reasons;

  bool get isLow => level == ReadinessLevel.low;

  bool get isHigh => level == ReadinessLevel.high;
}

class WorkoutReadinessService {
  WorkoutReadinessService({HealthService? healthService})
    : _healthService = healthService ?? HealthService();

  static const int _shortSleepMinutes = 360;
  static const int _goodSleepMinutes = 450;
  static const double _lowHrvMs = 30;
  static const double _highHrvMs = 60;
  static const int _moodLookbackDays = 2;

  final HealthService _healthService;

  Future<WorkoutReadiness> assess(List<WorkoutSessionEntity> history) async {
    HealthSnapshot? snapshot;
    try {
      if (await _healthService.hasPermissions()) {
        snapshot = await _healthService.fetchTodaySnapshot();
      }
    } catch (_) {
      snapshot = null;
    }
    return readinessOf(
      mood: _recentMood(history),
      sleepMinutes: snapshot == null || snapshot.sleepMinutes == 0
          ? null
          : snapshot.sleepMinutes,
      hrvMs: snapshot?.hrvMs,
    );
  }

  static WorkoutReadiness readinessOf({
    RecoveryMood? mood,
    int? sleepMinutes,
    double? hrvMs,
  }) {
    final low = <String>[];
    final high = <String>[];

    if (mood == RecoveryMood.sore) low.add('you reported feeling sore');
    if (mood == RecoveryMood.tired) low.add('you reported feeling tired');
    if (mood == RecoveryMood.great) high.add('you felt great last session');

    if (sleepMinutes != null) {
      final hours = (sleepMinutes / Duration.minutesPerHour).toStringAsFixed(1);
      if (sleepMinutes < _shortSleepMinutes) {
        low.add('you slept ${hours}h');
      } else if (sleepMinutes >= _goodSleepMinutes) {
        high.add('you slept ${hours}h');
      }
    }

    if (hrvMs != null) {
      if (hrvMs < _lowHrvMs) low.add('your HRV is low');
      if (hrvMs >= _highHrvMs) high.add('your HRV is strong');
    }

    if (low.isNotEmpty) {
      return WorkoutReadiness(level: ReadinessLevel.low, reasons: low);
    }
    if (high.length >= 2) {
      return WorkoutReadiness(level: ReadinessLevel.high, reasons: high);
    }
    return WorkoutReadiness(level: ReadinessLevel.normal, reasons: high);
  }

  RecoveryMood? _recentMood(List<WorkoutSessionEntity> history) {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final cutoff = AppDateUtils.addDays(today, -_moodLookbackDays);
    WorkoutSessionEntity? latest;
    for (final session in history) {
      if (!session.isCompleted || session.recoveryMood == null) continue;
      if (session.date.isBefore(cutoff)) continue;
      if (latest == null || session.startedAt.isAfter(latest.startedAt)) {
        latest = session;
      }
    }
    return latest?.recoveryMood;
  }
}

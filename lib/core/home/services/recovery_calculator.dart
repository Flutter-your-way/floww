import 'package:floww/config/entities/health_day_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/home/models/home_view_data.dart';

class RecoveryCalculator {
  const RecoveryCalculator();

  static const double defaultSleepTargetHours = 8;
  static const double defaultStepsTarget = 10000;
  static const int minimumBaselineDays = 3;
  static const int baselineWindowDays = 14;

  static const double _sleepWeight = 0.45;
  static const double _hrvWeight = 0.35;
  static const double _energyWeight = 0.2;

  static const double _hrvFloorRatio = 0.5;
  static const double _hrvCeilingRatio = 1.25;
  static const double _hrvAbsoluteFloorMs = 20;
  static const double _hrvAbsoluteRangeMs = 60;
  static const double _restingHeartRateTolerance = 0.1;
  static const double _restingHeartRateRange = 0.2;

  static const int _highFloor = 75;
  static const int _moderateFloor = 50;

  RecoveryDetail build({
    required List<HealthDayLog> history,
    required DateTime date,
    double? sleepTargetHours,
    double? stepsTarget,
  }) {
    final today = _logFor(history, date);
    if (today == null || !today.hasData) return RecoveryDetail.empty;

    final baseline = _baselineOf(history, date);
    final metrics = <RecoveryMetric>[];
    var totalWeight = 0.0;
    var total = 0.0;

    void add(RecoveryMetric? metric, double weight) {
      if (metric == null) return;
      metrics.add(metric);
      totalWeight += weight;
      total += weight * metric.percent;
    }

    add(_sleepMetric(today, sleepTargetHours), _sleepWeight);
    add(_hrvMetric(today, baseline.hrvMs), _hrvWeight);
    add(
      _energyMetric(today, baseline.restingHeartRate, stepsTarget),
      _energyWeight,
    );

    if (metrics.isEmpty) return RecoveryDetail.empty;

    final percent = (total / totalWeight).round();

    return RecoveryDetail(
      percent: percent,
      levelLabel: levelOf(percent),
      metrics: metrics,
    );
  }

  static String levelOf(int percent) {
    if (percent >= _highFloor) return 'High';
    if (percent >= _moderateFloor) return 'Moderate';
    return 'Low';
  }

  RecoveryMetric? _sleepMetric(HealthDayLog today, double? targetHours) {
    if (today.sleepMinutes <= 0) return null;
    final target =
        (targetHours ?? defaultSleepTargetHours) * Duration.minutesPerHour;
    final percent = _percent(today.sleepMinutes / target);
    return RecoveryMetric(
      emoji: '😴',
      label: 'Sleep',
      valueLabel: sleepLabel(today.sleepMinutes),
      percent: percent,
      accent: RecoveryMetricAccent.sleep,
    );
  }

  RecoveryMetric? _hrvMetric(HealthDayLog today, double? baselineMs) {
    final hrv = today.hrvMs;
    if (hrv == null) return null;

    final double ratio;
    if (baselineMs == null || baselineMs <= 0) {
      ratio = (hrv - _hrvAbsoluteFloorMs) / _hrvAbsoluteRangeMs;
    } else {
      ratio =
          ((hrv / baselineMs) - _hrvFloorRatio) /
          (_hrvCeilingRatio - _hrvFloorRatio);
    }

    return RecoveryMetric(
      emoji: '💚',
      label: 'HRV',
      valueLabel: '${hrv.round()}ms',
      percent: _percent(ratio),
      accent: RecoveryMetricAccent.hrv,
    );
  }

  RecoveryMetric? _energyMetric(
    HealthDayLog today,
    double? baselineRestingHeartRate,
    double? stepsTarget,
  ) {
    final scores = <double>[];

    final resting = today.restingHeartRate;
    if (resting != null &&
        baselineRestingHeartRate != null &&
        baselineRestingHeartRate > 0) {
      final ceiling =
          baselineRestingHeartRate * (1 + _restingHeartRateTolerance);
      final range = baselineRestingHeartRate * _restingHeartRateRange;
      scores.add(((ceiling - resting) / range).clamp(0.0, 1.0));
    }

    if (today.steps > 0) {
      final target = stepsTarget ?? defaultStepsTarget;
      if (target > 0) scores.add((today.steps / target).clamp(0.0, 1.0));
    }

    if (scores.isEmpty) return null;

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final percent = _percent(average);

    return RecoveryMetric(
      emoji: '⚡',
      label: 'Energy',
      valueLabel: levelOf(percent),
      percent: percent,
      accent: RecoveryMetricAccent.energy,
    );
  }

  _RecoveryBaseline _baselineOf(List<HealthDayLog> history, DateTime date) {
    final today = AppDateUtils.dateOnly(date);
    final from = AppDateUtils.addDays(today, -baselineWindowDays);

    var hrvTotal = 0.0;
    var hrvCount = 0;
    var restingTotal = 0.0;
    var restingCount = 0;

    for (final log in history) {
      final day = AppDateUtils.dateOnly(log.date);
      if (!day.isAfter(from) || !day.isBefore(today)) continue;
      final hrv = log.hrvMs;
      if (hrv != null && hrv > 0) {
        hrvTotal += hrv;
        hrvCount++;
      }
      final resting = log.restingHeartRate;
      if (resting != null && resting > 0) {
        restingTotal += resting;
        restingCount++;
      }
    }

    return _RecoveryBaseline(
      hrvMs: hrvCount < minimumBaselineDays ? null : hrvTotal / hrvCount,
      restingHeartRate: restingCount < minimumBaselineDays
          ? null
          : restingTotal / restingCount,
    );
  }

  static String sleepLabel(int minutes) {
    final hours = minutes ~/ Duration.minutesPerHour;
    final rest = minutes % Duration.minutesPerHour;
    return hours == 0 ? '${rest}m' : '${hours}h ${rest}m';
  }

  static HealthDayLog? _logFor(List<HealthDayLog> history, DateTime date) {
    for (final log in history) {
      if (AppDateUtils.isSameDay(log.date, date)) return log;
    }
    return null;
  }

  static int _percent(double ratio) => (ratio.clamp(0.0, 1.0) * 100).round();
}

class _RecoveryBaseline {
  const _RecoveryBaseline({this.hrvMs, this.restingHeartRate});

  final double? hrvMs;
  final double? restingHeartRate;
}

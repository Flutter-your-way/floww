import 'package:floww/config/utils/dates/app_date_utils.dart';

enum HealthTrend { up, down, flat }

class HealthSample {
  const HealthSample({required this.value, required this.at});

  final double value;
  final DateTime at;
}

class HealthMetricReading {
  const HealthMetricReading({
    required this.value,
    required this.at,
    this.previous,
  });

  static const double _flatThreshold = 0.005;

  final double value;
  final DateTime at;
  final double? previous;

  HealthTrend get trend {
    final previous = this.previous;
    if (previous == null || previous == 0) return HealthTrend.flat;
    final change = (value - previous) / previous.abs();
    if (change.abs() < _flatThreshold) return HealthTrend.flat;
    return change > 0 ? HealthTrend.up : HealthTrend.down;
  }

  static HealthMetricReading? latestOf(List<HealthSample> samples) {
    if (samples.isEmpty) return null;
    final totals = <DateTime, double>{};
    final counts = <DateTime, int>{};
    final lastAt = <DateTime, DateTime>{};
    for (final sample in samples) {
      final day = AppDateUtils.dateOnly(sample.at);
      totals[day] = (totals[day] ?? 0) + sample.value;
      counts[day] = (counts[day] ?? 0) + 1;
      final seen = lastAt[day];
      if (seen == null || sample.at.isAfter(seen)) lastAt[day] = sample.at;
    }
    final days = totals.keys.toList()..sort();
    final latest = days.last;
    final previous = days.length > 1 ? days[days.length - 2] : null;
    return HealthMetricReading(
      value: totals[latest]! / counts[latest]!,
      at: lastAt[latest]!,
      previous: previous == null ? null : totals[previous]! / counts[previous]!,
    );
  }
}

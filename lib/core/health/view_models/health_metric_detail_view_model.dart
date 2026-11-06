import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/health/models/health_metric_kind.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';
import 'package:floww/core/health/models/health_vitals.dart';

class HealthMetricHistoryRow {
  const HealthMetricHistoryRow({
    required this.dateLabel,
    required this.valueLabel,
    required this.isLatest,
  });

  final String dateLabel;
  final String valueLabel;
  final bool isLatest;
}

class HealthMetricDetailViewModel extends ChangeNotifier {
  HealthMetricDetailViewModel({
    required this.kind,
    required HealthVitals vitals,
    required this.sourceName,
  }) : _reading = vitals.readingOf(kind),
       _range = HealthMetricRange.month;

  static const int _axisLabelCount = 4;
  static const int _dateLabelCount = 4;
  static const int _maxDotCount = 31;
  static const double _axisPadding = 0.1;
  static const String _empty = '--';

  final HealthMetricKind kind;
  final String sourceName;

  HealthMetricReading? _reading;
  HealthMetricRange _range;

  void updateVitals(HealthVitals vitals) {
    final next = vitals.readingOf(kind);
    if (identical(next, _reading)) return;
    _reading = next;
    notifyListeners();
  }

  void selectRange(HealthMetricRange range) {
    if (range == _range) return;
    _range = range;
    notifyListeners();
  }

  String get title => kind.title;

  String get unit => kind.unit;

  String get about => kind.about;

  String get aboutTitle => 'About ${kind.label}';

  String get chartTitle => 'Trend';

  String get historyTitle => 'History';

  String get averageLabel => 'Average';

  String get lowestLabel => 'Lowest';

  String get highestLabel => 'Highest';

  String get sourceLabel => 'From $sourceName';

  String get emptyTitle => 'No ${kind.label} readings yet';

  String get emptyMessage =>
      'Once $sourceName records ${kind.label}, your graph and history will '
      'appear here.';

  String get emptyRangeMessage =>
      'Not enough readings in this range to draw a graph.';

  bool get hasReading => _reading != null;

  List<HealthMetricRange> get ranges => kind.ranges;

  HealthMetricRange get range => _range;

  String rangeLabelOf(HealthMetricRange range) => range.label;

  String get latestValueLabel {
    final reading = _reading;
    return reading == null ? _empty : kind.format(reading.value);
  }

  String get latestDateLabel {
    final reading = _reading;
    if (reading == null) return '';
    return 'Latest · ${AppDateUtils.relativeDay(reading.at)}';
  }

  HealthTrend get trend => _reading?.trend ?? HealthTrend.flat;

  bool? get isImproving {
    final higherIsBetter = kind.higherIsBetter;
    if (higherIsBetter == null || trend == HealthTrend.flat) return null;
    return (trend == HealthTrend.up) == higherIsBetter;
  }

  String? get changeLabel {
    final reading = _reading;
    final previous = reading?.previous;
    if (reading == null || previous == null || trend == HealthTrend.flat) {
      return null;
    }
    final delta = (reading.value - previous).abs();
    final direction = trend == HealthTrend.up ? 'Up' : 'Down';
    return '$direction ${kind.formatWithUnit(delta)} from last reading';
  }

  List<HealthSample> get _rangeSamples {
    final reading = _reading;
    if (reading == null) return const [];
    final from = AppDateUtils.addDays(DateTime.now(), 1 - _range.days);
    return reading.historySince(from);
  }

  List<double> get chartSamples => [
    for (final sample in _rangeSamples) sample.value,
  ];

  bool get hasChart => chartSamples.length >= 2;

  bool get showDots => chartSamples.length <= _maxDotCount;

  double get axisMin {
    final samples = chartSamples;
    if (samples.isEmpty) return 0;
    return samples.reduce(math.min) - _paddingOf(samples);
  }

  double get axisMax {
    final samples = chartSamples;
    if (samples.isEmpty) return 0;
    return samples.reduce(math.max) + _paddingOf(samples);
  }

  double _paddingOf(List<double> samples) {
    final span = samples.reduce(math.max) - samples.reduce(math.min);
    if (span > 0) return span * _axisPadding;
    return math.max(1, samples.first.abs() * _axisPadding);
  }

  List<String> get axisLabels {
    if (!hasChart) return const [];
    final min = axisMin;
    final step = (axisMax - min) / (_axisLabelCount - 1);
    return [
      for (var index = _axisLabelCount - 1; index >= 0; index--)
        kind.format(min + step * index),
    ];
  }

  List<String> get dateLabels {
    final samples = _rangeSamples;
    if (samples.length < 2) return const [];
    final count = math.min(_dateLabelCount, samples.length);
    final step = (samples.length - 1) / (count - 1);
    return [
      for (var index = 0; index < count; index++)
        _dateLabelOf(samples[(step * index).round()].at),
    ];
  }

  String _dateLabelOf(DateTime date) => _range == HealthMetricRange.year
      ? AppDateUtils.shortMonthYear(date)
      : AppDateUtils.shortMonthDay(date);

  String get averageValue {
    final samples = chartSamples;
    if (samples.isEmpty) return _empty;
    final total = samples.reduce((a, b) => a + b);
    return kind.formatWithUnit(total / samples.length);
  }

  String get lowestValue {
    final samples = chartSamples;
    if (samples.isEmpty) return _empty;
    return kind.formatWithUnit(samples.reduce(math.min));
  }

  String get highestValue {
    final samples = chartSamples;
    if (samples.isEmpty) return _empty;
    return kind.formatWithUnit(samples.reduce(math.max));
  }

  List<HealthMetricHistoryRow> get historyRows {
    final samples = _rangeSamples.reversed.toList();
    return [
      for (var index = 0; index < samples.length; index++)
        HealthMetricHistoryRow(
          dateLabel: _range == HealthMetricRange.year
              ? AppDateUtils.dayMonth(samples[index].at, withYear: true)
              : AppDateUtils.relativeDay(samples[index].at),
          valueLabel: kind.formatWithUnit(samples[index].value),
          isLatest: index == 0,
        ),
    ];
  }

  bool get hasHistory => historyRows.isNotEmpty;
}

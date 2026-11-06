import 'package:floww/core/health/models/health_metric_kind.dart';
import 'package:floww/core/health/models/health_metric_reading.dart';
import 'package:floww/core/health/models/health_vitals.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';
import 'package:floww/core/home/providers/daily_metrics_selection_provider.dart';

class DailyMetricsPresenter {
  DailyMetricsPresenter._();

  static const String _empty = '--';
  static const String _noData = 'No data yet';

  static Set<HealthMetricKind> availableOf(HealthVitals vitals) => {
    for (final kind in HealthMetricKindX.daily)
      if (vitals.readingOf(kind) != null) kind,
  };

  static DailyMetricsViewData of(
    HealthVitals vitals, {
    required String source,
    required DailyMetricsSelectionProvider selection,
  }) {
    final available = availableOf(vitals);
    return DailyMetricsViewData(
      title: 'Daily Metrics',
      infoTitle: 'Daily Metrics',
      infoMessage:
          'These readings come from $source. Each shows your latest value, '
          'and the arrow compares it with the reading before. Green means the '
          'change is good for your recovery, red means keep an eye on it. '
          'Tap a metric to see its history, or tap the sliders to choose '
          'which metrics appear here.',
      bodyCompositionLabel: 'View Body Composition',
      hasData: vitals.hasAnyData,
      canCustomize: available.length > 1,
      promptMessage:
          'Allow $source access to see your HRV, resting heart rate, VO2 max, '
          'blood oxygen, temperature and body composition here.',
      allowLabel: 'Allow Access',
      tiles: [
        for (final kind in selection.visibleOf(available))
          tileOf(kind, vitals.readingOf(kind)),
      ],
    );
  }

  static DailyMetricsPickerViewData pickerOf(
    HealthVitals vitals, {
    required String source,
    required DailyMetricsSelectionProvider selection,
  }) {
    final available = availableOf(vitals);
    return DailyMetricsPickerViewData(
      title: 'Choose Metrics',
      subtitle:
          'Pick what shows on your home screen. Metrics $source has '
          'no readings for yet are unavailable.',
      options: [
        for (final kind in HealthMetricKindX.daily)
          DailyMetricOption(
            kind: kind,
            label: kind.label,
            detail: _detailOf(kind, vitals.readingOf(kind)),
            isAvailable: available.contains(kind),
            isSelected:
                available.contains(kind) &&
                selection.isSelected(kind, available),
            canToggle:
                available.contains(kind) &&
                selection.canToggleOff(kind, available),
          ),
      ],
    );
  }

  static BodyCompositionViewData bodyCompositionOf(
    HealthVitals vitals, {
    required String source,
  }) {
    return BodyCompositionViewData(
      title: 'Body Composition',
      subtitle: 'Latest measurements from $source',
      emptyMessage:
          'No body measurements yet. Log weight or body fat in $source, '
          'or use a smart scale that syncs to it.',
      hasData: vitals.hasBodyComposition,
      tiles: [
        for (final kind in HealthMetricKindX.body)
          tileOf(kind, vitals.readingOf(kind)),
      ],
    );
  }

  static DailyMetricTile tileOf(
    HealthMetricKind kind,
    HealthMetricReading? reading,
  ) {
    if (reading == null) {
      return DailyMetricTile(
        kind: kind,
        label: kind.label,
        value: _empty,
        unit: kind.unit,
      );
    }
    final trend = reading.trend;
    return DailyMetricTile(
      kind: kind,
      label: kind.label,
      value: kind.format(reading.value),
      unit: kind.unit,
      trend: trend,
      tone: toneOf(trend, kind.higherIsBetter),
      hasReading: true,
    );
  }

  static DailyMetricTone toneOf(HealthTrend trend, bool? higherIsBetter) {
    if (higherIsBetter == null || trend == HealthTrend.flat) {
      return DailyMetricTone.neutral;
    }
    final improving = (trend == HealthTrend.up) == higherIsBetter;
    return improving ? DailyMetricTone.positive : DailyMetricTone.negative;
  }

  static String _detailOf(HealthMetricKind kind, HealthMetricReading? reading) {
    if (reading == null) return _noData;
    return kind.formatWithUnit(reading.value);
  }
}

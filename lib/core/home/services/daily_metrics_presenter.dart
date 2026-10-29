import 'package:floww/core/health/models/health_metric_reading.dart';
import 'package:floww/core/health/models/health_vitals.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';

class DailyMetricsPresenter {
  DailyMetricsPresenter._();

  static const String _empty = '--';

  static DailyMetricsViewData of(
    HealthVitals vitals, {
    required String source,
  }) {
    return DailyMetricsViewData(
      title: 'Daily Metrics',
      infoTitle: 'Daily Metrics',
      infoMessage:
          'These readings come from $source. Each shows your latest value, '
          'and the arrow compares it with the reading before. Green means the '
          'change is good for your recovery, red means keep an eye on it. '
          'Wear your watch overnight to fill in HRV, temperature and '
          'respiratory rate.',
      bodyCompositionLabel: 'View Body Composition',
      hasData: vitals.hasAnyData,
      promptMessage:
          'Allow $source access to see your HRV, resting heart rate, VO2 max, '
          'blood oxygen, temperature and body composition here.',
      allowLabel: 'Allow Access',
      sections: [
        DailyMetricSection(
          kind: DailyMetricSectionKind.recovery,
          title: 'Recovery',
          tiles: [
            _tile('HRV', vitals.hrv, 'ms', digits: 0, higherIsBetter: true),
            _tile(
              'Resting HR',
              vitals.restingHeartRate,
              'bpm',
              digits: 0,
              higherIsBetter: false,
            ),
          ],
        ),
        DailyMetricSection(
          kind: DailyMetricSectionKind.cardio,
          title: 'Cardio',
          tiles: [
            _tile(
              'VO2 Max',
              vitals.vo2Max,
              'ml/kg/min',
              digits: 1,
              higherIsBetter: true,
            ),
            _tile(
              'HR Recovery',
              vitals.heartRateRecovery,
              'bpm',
              digits: 0,
              higherIsBetter: true,
            ),
          ],
        ),
        DailyMetricSection(
          kind: DailyMetricSectionKind.body,
          title: 'Body',
          tiles: [
            _tile(
              'O2 Saturation',
              vitals.oxygenSaturation,
              '%',
              digits: 1,
              higherIsBetter: true,
            ),
            _tile('Skin Temperature', vitals.skinTemperature, '°C', digits: 1),
            _tile(
              'Respiratory Rate',
              vitals.respiratoryRate,
              'brpm',
              digits: 1,
            ),
          ],
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
        _tile('Weight', vitals.weight, 'kg', digits: 1),
        _tile(
          'Body Fat',
          vitals.bodyFat,
          '%',
          digits: 1,
          higherIsBetter: false,
        ),
        _tile(
          'Lean Mass',
          vitals.leanMass,
          'kg',
          digits: 1,
          higherIsBetter: true,
        ),
        _tile('BMI', vitals.bodyMassIndex, '', digits: 1),
      ],
    );
  }

  static DailyMetricTile _tile(
    String label,
    HealthMetricReading? reading,
    String unit, {
    required int digits,
    bool? higherIsBetter,
  }) {
    if (reading == null) {
      return DailyMetricTile(label: label, value: _empty, unit: unit);
    }
    final trend = reading.trend;
    return DailyMetricTile(
      label: label,
      value: reading.value.toStringAsFixed(digits),
      unit: unit,
      trend: trend,
      tone: _toneOf(trend, higherIsBetter),
    );
  }

  static DailyMetricTone _toneOf(HealthTrend trend, bool? higherIsBetter) {
    if (higherIsBetter == null || trend == HealthTrend.flat) {
      return DailyMetricTone.neutral;
    }
    final improving = (trend == HealthTrend.up) == higherIsBetter;
    return improving ? DailyMetricTone.positive : DailyMetricTone.negative;
  }
}

import 'package:floww/core/health/models/health_metric_reading.dart';

class HealthVitals {
  const HealthVitals({
    this.hrv,
    this.restingHeartRate,
    this.vo2Max,
    this.heartRateRecovery,
    this.oxygenSaturation,
    this.skinTemperature,
    this.respiratoryRate,
    this.weight,
    this.bodyFat,
    this.leanMass,
    this.bodyMassIndex,
  });

  static const HealthVitals empty = HealthVitals();

  final HealthMetricReading? hrv;
  final HealthMetricReading? restingHeartRate;
  final HealthMetricReading? vo2Max;
  final HealthMetricReading? heartRateRecovery;
  final HealthMetricReading? oxygenSaturation;
  final HealthMetricReading? skinTemperature;
  final HealthMetricReading? respiratoryRate;
  final HealthMetricReading? weight;
  final HealthMetricReading? bodyFat;
  final HealthMetricReading? leanMass;
  final HealthMetricReading? bodyMassIndex;

  bool get hasAnyData =>
      hrv != null ||
      restingHeartRate != null ||
      vo2Max != null ||
      heartRateRecovery != null ||
      oxygenSaturation != null ||
      skinTemperature != null ||
      respiratoryRate != null ||
      hasBodyComposition;

  bool get hasBodyComposition =>
      weight != null ||
      bodyFat != null ||
      leanMass != null ||
      bodyMassIndex != null;
}

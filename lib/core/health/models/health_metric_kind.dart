enum HealthMetricRange { week, month, year }

extension HealthMetricRangeX on HealthMetricRange {
  int get days => switch (this) {
    HealthMetricRange.week => 7,
    HealthMetricRange.month => 30,
    HealthMetricRange.year => 365,
  };

  String get label => switch (this) {
    HealthMetricRange.week => '7D',
    HealthMetricRange.month => '30D',
    HealthMetricRange.year => '1Y',
  };
}

enum HealthMetricKind {
  hrv,
  restingHeartRate,
  vo2Max,
  heartRateRecovery,
  oxygenSaturation,
  skinTemperature,
  respiratoryRate,
  weight,
  bodyFat,
  leanMass,
  bodyMassIndex,
}

extension HealthMetricKindX on HealthMetricKind {
  static const List<HealthMetricKind> daily = [
    HealthMetricKind.hrv,
    HealthMetricKind.restingHeartRate,
    HealthMetricKind.vo2Max,
    HealthMetricKind.heartRateRecovery,
    HealthMetricKind.oxygenSaturation,
    HealthMetricKind.skinTemperature,
    HealthMetricKind.respiratoryRate,
  ];

  static const List<HealthMetricKind> body = [
    HealthMetricKind.weight,
    HealthMetricKind.bodyFat,
    HealthMetricKind.leanMass,
    HealthMetricKind.bodyMassIndex,
  ];

  static const List<HealthMetricKind> defaultDaily = [
    HealthMetricKind.hrv,
    HealthMetricKind.restingHeartRate,
    HealthMetricKind.vo2Max,
    HealthMetricKind.oxygenSaturation,
  ];

  String get label => switch (this) {
    HealthMetricKind.hrv => 'HRV',
    HealthMetricKind.restingHeartRate => 'Resting HR',
    HealthMetricKind.vo2Max => 'VO2 Max',
    HealthMetricKind.heartRateRecovery => 'HR Recovery',
    HealthMetricKind.oxygenSaturation => 'O2 Saturation',
    HealthMetricKind.skinTemperature => 'Skin Temperature',
    HealthMetricKind.respiratoryRate => 'Respiratory Rate',
    HealthMetricKind.weight => 'Weight',
    HealthMetricKind.bodyFat => 'Body Fat',
    HealthMetricKind.leanMass => 'Lean Mass',
    HealthMetricKind.bodyMassIndex => 'BMI',
  };

  String get title => switch (this) {
    HealthMetricKind.hrv => 'Heart Rate Variability',
    HealthMetricKind.restingHeartRate => 'Resting Heart Rate',
    HealthMetricKind.heartRateRecovery => 'Heart Rate Recovery',
    HealthMetricKind.oxygenSaturation => 'Blood Oxygen',
    HealthMetricKind.bodyMassIndex => 'Body Mass Index',
    _ => label,
  };

  String get unit => switch (this) {
    HealthMetricKind.hrv => 'ms',
    HealthMetricKind.restingHeartRate => 'bpm',
    HealthMetricKind.vo2Max => 'ml/kg/min',
    HealthMetricKind.heartRateRecovery => 'bpm',
    HealthMetricKind.oxygenSaturation => '%',
    HealthMetricKind.skinTemperature => '°C',
    HealthMetricKind.respiratoryRate => 'brpm',
    HealthMetricKind.weight => 'kg',
    HealthMetricKind.bodyFat => '%',
    HealthMetricKind.leanMass => 'kg',
    HealthMetricKind.bodyMassIndex => '',
  };

  int get digits => switch (this) {
    HealthMetricKind.hrv ||
    HealthMetricKind.restingHeartRate ||
    HealthMetricKind.heartRateRecovery => 0,
    _ => 1,
  };

  bool? get higherIsBetter => switch (this) {
    HealthMetricKind.hrv ||
    HealthMetricKind.vo2Max ||
    HealthMetricKind.heartRateRecovery ||
    HealthMetricKind.oxygenSaturation ||
    HealthMetricKind.leanMass => true,
    HealthMetricKind.restingHeartRate || HealthMetricKind.bodyFat => false,
    _ => null,
  };

  String format(double value) => value.toStringAsFixed(digits);

  String formatWithUnit(double value) =>
      unit.isEmpty ? format(value) : '${format(value)} $unit';

  bool get isLongTerm => body.contains(this) || this == HealthMetricKind.vo2Max;

  List<HealthMetricRange> get ranges => isLongTerm
      ? HealthMetricRange.values
      : const [HealthMetricRange.week, HealthMetricRange.month];

  String get about => switch (this) {
    HealthMetricKind.hrv =>
      'The variation in time between heartbeats. A higher HRV than your '
          'usual usually means you have recovered well and are ready to push.',
    HealthMetricKind.restingHeartRate =>
      'Your heart rate while fully at rest. A lower resting heart rate '
          'generally reflects better cardio fitness and recovery.',
    HealthMetricKind.vo2Max =>
      'The maximum amount of oxygen your body can use during exercise. '
          'It is one of the strongest markers of cardio fitness.',
    HealthMetricKind.heartRateRecovery =>
      'How much your heart rate drops in the minute after hard effort. '
          'A bigger drop means a fitter, faster-recovering heart.',
    HealthMetricKind.oxygenSaturation =>
      'The share of oxygen carried in your blood. Healthy readings usually '
          'sit between 95% and 100%.',
    HealthMetricKind.skinTemperature =>
      'Your wrist temperature measured overnight. Shifts from your usual '
          'can signal illness, stress or poor recovery.',
    HealthMetricKind.respiratoryRate =>
      'Breaths per minute while you sleep. It is usually steady, so a jump '
          'can be an early sign your body is under strain.',
    HealthMetricKind.weight =>
      'Your body weight from manual logs or a connected smart scale.',
    HealthMetricKind.bodyFat =>
      'The share of your body weight that is fat tissue.',
    HealthMetricKind.leanMass =>
      'Everything in your body except fat: muscle, bone, organs and water.',
    HealthMetricKind.bodyMassIndex =>
      'Your weight relative to your height. A rough guide that does not '
          'account for muscle mass.',
  };
}

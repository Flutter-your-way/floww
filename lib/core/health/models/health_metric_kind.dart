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
  steps,
  sleep,
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
    HealthMetricKind.steps,
    HealthMetricKind.sleep,
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
    HealthMetricKind.steps,
    HealthMetricKind.sleep,
    HealthMetricKind.hrv,
    HealthMetricKind.restingHeartRate,
    HealthMetricKind.vo2Max,
    HealthMetricKind.oxygenSaturation,
  ];

  static const List<HealthMetricKind> addedInV2 = [
    HealthMetricKind.steps,
    HealthMetricKind.sleep,
  ];

  String get label => switch (this) {
    HealthMetricKind.steps => 'Steps',
    HealthMetricKind.sleep => 'Sleep',
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
    HealthMetricKind.sleep => 'Time Asleep',
    HealthMetricKind.hrv => 'Heart Rate Variability',
    HealthMetricKind.restingHeartRate => 'Resting Heart Rate',
    HealthMetricKind.heartRateRecovery => 'Heart Rate Recovery',
    HealthMetricKind.oxygenSaturation => 'Blood Oxygen',
    HealthMetricKind.bodyMassIndex => 'Body Mass Index',
    _ => label,
  };

  String get unit => switch (this) {
    HealthMetricKind.steps => 'steps',
    HealthMetricKind.sleep => '',
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
    HealthMetricKind.steps ||
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

  String format(double value) => switch (this) {
    HealthMetricKind.steps => _grouped(value.round()),
    HealthMetricKind.sleep => _duration(value),
    _ => value.toStringAsFixed(digits),
  };

  static String _grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _duration(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String formatWithUnit(double value) =>
      unit.isEmpty ? format(value) : '${format(value)} $unit';

  bool get isLongTerm => body.contains(this) || this == HealthMetricKind.vo2Max;

  List<HealthMetricRange> get ranges => isLongTerm
      ? HealthMetricRange.values
      : const [HealthMetricRange.week, HealthMetricRange.month];

  String get about => switch (this) {
    HealthMetricKind.steps =>
      'Your total steps for the day from your phone and watch. Today\'s '
          'count keeps climbing until midnight.',
    HealthMetricKind.sleep =>
      'Total time asleep for the night, including core, deep and REM '
          'sleep. Most adults recover best with 7 to 9 hours.',
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

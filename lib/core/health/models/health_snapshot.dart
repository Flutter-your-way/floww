class HealthSnapshot {
  const HealthSnapshot({
    required this.steps,
    required this.activeCaloriesKcal,
    required this.restingHeartRate,
    required this.sleepMinutes,
    required this.workoutCount,
    required this.syncedAt,
    this.hrvMs,
  });

  final int steps;
  final int activeCaloriesKcal;
  final int? restingHeartRate;
  final int sleepMinutes;
  final int workoutCount;
  final DateTime? syncedAt;
  final double? hrvMs;

  static const HealthSnapshot empty = HealthSnapshot(
    steps: 0,
    activeCaloriesKcal: 0,
    restingHeartRate: null,
    sleepMinutes: 0,
    workoutCount: 0,
    syncedAt: null,
  );

  bool get hasData =>
      steps > 0 ||
      activeCaloriesKcal > 0 ||
      sleepMinutes > 0 ||
      workoutCount > 0 ||
      restingHeartRate != null ||
      hrvMs != null;

  String get stepsLabel => _grouped(steps);

  String get sleepLabel {
    final hours = sleepMinutes ~/ 60;
    final minutes = sleepMinutes % 60;
    return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
  }

  String get hrvLabel {
    final hrv = hrvMs;
    return hrv == null ? '—' : '${hrv.round()}ms';
  }

  String get summaryLabel {
    final parts = <String>[];
    if (steps > 0) parts.add('$stepsLabel steps');
    if (sleepMinutes > 0) parts.add('$sleepLabel sleep');
    if (restingHeartRate != null) parts.add('$restingHeartRate bpm resting');
    if (activeCaloriesKcal > 0 && parts.length < 3) {
      parts.add('$activeCaloriesKcal kcal');
    }
    return parts.isEmpty ? 'No Apple Health data logged today' : parts.join(' · ');
  }

  static String _grouped(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

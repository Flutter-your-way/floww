class FlowReadinessCalculator {
  const FlowReadinessCalculator();

  static const double sleepWeight = 0.6;
  static const double hrvWeight = 0.4;
  static const double defaultSleepTargetHours = 8;
  static const double hrvFloorMs = 20;
  static const double hrvRangeMs = 60;

  int readinessOf({
    int? baseline,
    int sleepMinutes = 0,
    double? hrvMs,
    double? sleepTargetHours,
  }) {
    var total = 0.0;
    var weight = 0.0;

    if (sleepMinutes > 0) {
      final targetMinutes =
          (sleepTargetHours ?? defaultSleepTargetHours) *
          Duration.minutesPerHour;
      total += (sleepMinutes / targetMinutes).clamp(0.0, 1.0) * sleepWeight;
      weight += sleepWeight;
    }

    final hrv = hrvMs;
    if (hrv != null && hrv > 0) {
      total += ((hrv - hrvFloorMs) / hrvRangeMs).clamp(0.0, 1.0) * hrvWeight;
      weight += hrvWeight;
    }

    if (weight > 0) return (total / weight * 100).round().clamp(0, 100);
    return (baseline ?? 0).clamp(0, 100);
  }
}

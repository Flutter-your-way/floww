enum MeasurementSystem {
  metric('Metric'),
  imperial('Imperial');

  const MeasurementSystem(this.label);

  final String label;

  static MeasurementSystem fromLabel(String? label) =>
      MeasurementSystem.values.firstWhere(
        (system) => system.label == label,
        orElse: () => MeasurementSystem.metric,
      );
}

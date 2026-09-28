enum SetType {
  warmup('warmup', 'Warm-up', 'W'),
  working('working', 'Working', ''),
  drop('drop', 'Drop', 'D'),
  failure('failure', 'Failure', 'F');

  const SetType(this.id, this.label, this.badge);

  final String id;
  final String label;
  final String badge;

  bool get countsTowardVolume => this != SetType.warmup;

  static SetType fromId(String? id) =>
      values.firstWhere((type) => type.id == id, orElse: () => SetType.working);
}

enum TrackingMode {
  reps('reps'),
  duration('duration');

  const TrackingMode(this.id);

  final String id;

  static TrackingMode fromId(String? id) => values.firstWhere(
    (mode) => mode.id == id,
    orElse: () => TrackingMode.reps,
  );
}

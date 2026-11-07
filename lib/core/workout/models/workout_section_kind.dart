enum WorkoutSectionKind {
  warmUp('warm-up', '🔥', 'Warm-up'),
  main('main-exercises', '⚡', 'Workout'),
  coolDown('cool-down', '🌊', 'Cool-down');

  const WorkoutSectionKind(this.id, this.glyph, this.title);

  final String id;
  final String glyph;
  final String title;

  static WorkoutSectionKind fromId(String? id) => values.firstWhere(
    (kind) => kind.id == id,
    orElse: () => WorkoutSectionKind.main,
  );
}

enum WorkoutSectionStatus { completed, active, pending }

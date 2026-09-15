enum WorkoutSectionStatus { completed, active, pending }

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightKg,
  });

  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final double? weightKg;

  bool get isBodyweight => weightKg == null;

  int get volumeKg => isBodyweight ? 0 : (weightKg! * sets * reps).round();
}

class WorkoutSectionGroup {
  const WorkoutSectionGroup({
    required this.id,
    required this.glyph,
    required this.title,
    required this.status,
    required this.exercises,
  });

  final String id;
  final String glyph;
  final String title;
  final WorkoutSectionStatus status;
  final List<WorkoutExercise> exercises;
}

class WorkoutDetail {
  const WorkoutDetail({
    required this.id,
    required this.name,
    required this.performedAt,
    required this.isCompleted,
    required this.durationSeconds,
    required this.volumeKg,
    required this.calories,
    required this.averageHeartRate,
    required this.sections,
    required this.insight,
    required this.notes,
  });

  final String id;
  final String name;
  final DateTime performedAt;
  final bool isCompleted;
  final int durationSeconds;
  final int volumeKg;
  final int calories;
  final int averageHeartRate;
  final List<WorkoutSectionGroup> sections;
  final String insight;
  final String notes;

  int get exerciseCount {
    var count = 0;
    for (final section in sections) {
      count += section.exercises.length;
    }
    return count;
  }
}

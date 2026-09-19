import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class LoggedSetEntry {
  const LoggedSetEntry({
    required this.reps,
    required this.loggedAt,
    this.weightKg,
  });

  factory LoggedSetEntry.fromJson(Map<String, dynamic> json) => LoggedSetEntry(
    reps: (json['reps'] as num? ?? 0).toInt(),
    loggedAt: DateTime.parse(json['loggedAt'] as String).toLocal(),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
  );

  final int reps;
  final DateTime loggedAt;
  final double? weightKg;

  double get volumeKg => (weightKg ?? 0) * reps;

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'loggedAt': AppDateUtils.isoKey(loggedAt),
    if (weightKg != null) 'weightKg': weightKg,
  };
}

class WorkoutEntryEntity {
  const WorkoutEntryEntity({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.section,
    required this.targetSets,
    required this.targetReps,
    required this.restSeconds,
    required this.repsInReserve,
    required this.met,
    required this.muscleShares,
    this.targetWeightKg,
    this.imageUrl,
    this.mistakes = const [],
    this.guidelines = const [],
    this.equipmentItems = const [],
    this.sets = const [],
    this.isSkipped = false,
  });

  factory WorkoutEntryEntity.fromCatalog(
    ExerciseCatalogEntry exercise, {
    required String id,
    required WorkoutSectionKind section,
    int? sets,
    int? reps,
    int? restSeconds,
    int? repsInReserve,
    double? weightKg,
  }) => WorkoutEntryEntity(
    id: id,
    exerciseId: exercise.id,
    name: exercise.name,
    section: section,
    targetSets: sets ?? exercise.defaultSets,
    targetReps: reps ?? exercise.defaultReps,
    restSeconds: restSeconds ?? exercise.defaultRestSeconds,
    repsInReserve: repsInReserve ?? exercise.defaultRepsInReserve,
    met: exercise.met,
    muscleShares: exercise.muscleShares,
    targetWeightKg: exercise.isBodyweight
        ? null
        : weightKg ?? exercise.defaultWeightKg,
    imageUrl: exercise.imageUrl,
    mistakes: exercise.mistakes,
    guidelines: exercise.guidelines,
    equipmentItems: exercise.equipmentItems,
  );

  factory WorkoutEntryEntity.fromJson(Map<String, dynamic> json) =>
      WorkoutEntryEntity(
        id: json['id'] as String,
        exerciseId: json['exerciseId'] as String? ?? json['id'] as String,
        name: json['name'] as String,
        section: WorkoutSectionKind.fromId(json['section'] as String?),
        targetSets: (json['targetSets'] as num? ?? 0).toInt(),
        targetReps: (json['targetReps'] as num? ?? 0).toInt(),
        restSeconds: (json['restSeconds'] as num? ?? 0).toInt(),
        repsInReserve: (json['repsInReserve'] as num? ?? 0).toInt(),
        met: (json['met'] as num? ?? 5).toDouble(),
        muscleShares: ExerciseCatalogEntry.sharesOf(json['muscleShares']),
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
        imageUrl: json['imageUrl'] as String?,
        mistakes: ExerciseCatalogEntry.cuesOf(json['mistakes']),
        guidelines: ExerciseCatalogEntry.cuesOf(json['guidelines']),
        equipmentItems: ExerciseCatalogEntry.cuesOf(json['equipmentItems']),
        sets: _setsOf(json['sets']),
        isSkipped: json['isSkipped'] as bool? ?? false,
      );

  final String id;
  final String exerciseId;
  final String name;
  final WorkoutSectionKind section;
  final int targetSets;
  final int targetReps;
  final int restSeconds;
  final int repsInReserve;
  final double met;
  final Map<String, double> muscleShares;
  final double? targetWeightKg;
  final String? imageUrl;
  final List<ExerciseCueEntry> mistakes;
  final List<ExerciseCueEntry> guidelines;
  final List<ExerciseCueEntry> equipmentItems;
  final List<LoggedSetEntry> sets;
  final bool isSkipped;

  bool get isBodyweight => targetWeightKg == null;

  bool get isComplete => sets.length >= targetSets;

  int get completedReps {
    var total = 0;
    for (final set in sets) {
      total += set.reps;
    }
    return total;
  }

  double get completedVolumeKg {
    var total = 0.0;
    for (final set in sets) {
      total += set.volumeKg;
    }
    return total;
  }

  double get targetVolumeKg => (targetWeightKg ?? 0) * targetSets * targetReps;

  double? get bestSetWeightKg {
    double? best;
    for (final set in sets) {
      final weight = set.weightKg;
      if (weight == null) continue;
      if (best == null || weight > best) best = weight;
    }
    return best;
  }

  int get bestSetReps {
    var best = 0;
    for (final set in sets) {
      if (set.reps > best) best = set.reps;
    }
    return best;
  }

  WorkoutEntryEntity copyWith({
    List<LoggedSetEntry>? sets,
    bool? isSkipped,
    int? targetSets,
    int? targetReps,
    int? restSeconds,
    double? targetWeightKg,
  }) => WorkoutEntryEntity(
    id: id,
    exerciseId: exerciseId,
    name: name,
    section: section,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    restSeconds: restSeconds ?? this.restSeconds,
    repsInReserve: repsInReserve,
    met: met,
    muscleShares: muscleShares,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    imageUrl: imageUrl,
    mistakes: mistakes,
    guidelines: guidelines,
    equipmentItems: equipmentItems,
    sets: sets ?? this.sets,
    isSkipped: isSkipped ?? this.isSkipped,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'name': name,
    'section': section.id,
    'targetSets': targetSets,
    'targetReps': targetReps,
    'restSeconds': restSeconds,
    'repsInReserve': repsInReserve,
    'met': met,
    'muscleShares': muscleShares,
    if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'mistakes': [for (final cue in mistakes) cue.toJson()],
    'guidelines': [for (final cue in guidelines) cue.toJson()],
    'equipmentItems': [for (final cue in equipmentItems) cue.toJson()],
    'sets': [for (final set in sets) set.toJson()],
    'isSkipped': isSkipped,
  };

  static List<LoggedSetEntry> _setsOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) LoggedSetEntry.fromJson(item),
    ];
  }
}

class WorkoutPlanEntity {
  const WorkoutPlanEntity({
    required this.id,
    required this.date,
    required this.name,
    required this.focus,
    required this.goal,
    required this.insight,
    required this.durationMinutes,
    required this.exercises,
    this.programId,
    this.programLabel = '',
    this.sessionId,
  });

  factory WorkoutPlanEntity.fromJson(Map<String, dynamic> json) =>
      WorkoutPlanEntity(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        name: json['name'] as String,
        focus: json['focus'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        insight: json['insight'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num? ?? 0).toInt(),
        exercises: entriesOf(json['exercises']),
        programId: json['programId'] as String?,
        programLabel: json['programLabel'] as String? ?? '',
        sessionId: json['sessionId'] as String?,
      );

  final String id;
  final DateTime date;
  final String name;
  final String focus;
  final String goal;
  final String insight;
  final int durationMinutes;
  final List<WorkoutEntryEntity> exercises;
  final String? programId;
  final String programLabel;
  final String? sessionId;

  int get totalSets {
    var count = 0;
    for (final exercise in exercises) {
      count += exercise.targetSets;
    }
    return count;
  }

  WorkoutPlanEntity copyWithExercises(List<WorkoutEntryEntity> exercises) =>
      WorkoutPlanEntity(
        id: id,
        date: date,
        name: name,
        focus: focus,
        goal: goal,
        insight: insight,
        durationMinutes: durationMinutes,
        exercises: exercises,
        programId: programId,
        programLabel: programLabel,
        sessionId: sessionId,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': AppDateUtils.dateKey(date),
    'name': name,
    'focus': focus,
    'goal': goal,
    'insight': insight,
    'durationMinutes': durationMinutes,
    'exercises': [for (final exercise in exercises) exercise.toJson()],
    if (programId != null) 'programId': programId,
    'programLabel': programLabel,
    if (sessionId != null) 'sessionId': sessionId,
  };

  static List<WorkoutEntryEntity> entriesOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) WorkoutEntryEntity.fromJson(item),
    ];
  }
}

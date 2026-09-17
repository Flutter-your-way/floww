import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';

class ProgramExerciseEntry {
  const ProgramExerciseEntry({
    required this.exerciseId,
    required this.section,
    this.sets,
    this.reps,
    this.restSeconds,
    this.repsInReserve,
    this.weightKg,
  });

  factory ProgramExerciseEntry.fromJson(Map<String, dynamic> json) =>
      ProgramExerciseEntry(
        exerciseId: json['exerciseId'] as String,
        section: WorkoutSectionKind.fromId(json['section'] as String?),
        sets: (json['sets'] as num?)?.toInt(),
        reps: (json['reps'] as num?)?.toInt(),
        restSeconds: (json['restSeconds'] as num?)?.toInt(),
        repsInReserve: (json['repsInReserve'] as num?)?.toInt(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
      );

  final String exerciseId;
  final WorkoutSectionKind section;
  final int? sets;
  final int? reps;
  final int? restSeconds;
  final int? repsInReserve;
  final double? weightKg;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'section': section.id,
    if (sets != null) 'sets': sets,
    if (reps != null) 'reps': reps,
    if (restSeconds != null) 'restSeconds': restSeconds,
    if (repsInReserve != null) 'repsInReserve': repsInReserve,
    if (weightKg != null) 'weightKg': weightKg,
  };
}

class ProgramDayEntry {
  const ProgramDayEntry({
    required this.weekday,
    required this.name,
    required this.focus,
    required this.goal,
    required this.durationMinutes,
    required this.exercises,
  });

  factory ProgramDayEntry.fromJson(Map<String, dynamic> json) =>
      ProgramDayEntry(
        weekday: (json['weekday'] as num? ?? DateTime.monday).toInt(),
        name: json['name'] as String,
        focus: json['focus'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num? ?? 45).toInt(),
        exercises: [
          for (final item in (json['exercises'] as List? ?? const []))
            if (item is Map<String, dynamic>)
              ProgramExerciseEntry.fromJson(item),
        ],
      );

  final int weekday;
  final String name;
  final String focus;
  final String goal;
  final int durationMinutes;
  final List<ProgramExerciseEntry> exercises;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'name': name,
    'focus': focus,
    'goal': goal,
    'durationMinutes': durationMinutes,
    'exercises': [for (final exercise in exercises) exercise.toJson()],
  };
}

class WorkoutProgramEntity {
  const WorkoutProgramEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.weeks,
    required this.days,
  });

  factory WorkoutProgramEntity.fromJson(Map<String, dynamic> json) =>
      WorkoutProgramEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        level: json['level'] as String? ?? '',
        weeks: (json['weeks'] as num? ?? 0).toInt(),
        days: [
          for (final item in (json['days'] as List? ?? const []))
            if (item is Map<String, dynamic>) ProgramDayEntry.fromJson(item),
        ],
      );

  final String id;
  final String name;
  final String description;
  final String level;
  final int weeks;
  final List<ProgramDayEntry> days;

  int get sessionsPerWeek => days.length;

  ProgramDayEntry? dayFor(DateTime date) {
    for (final day in days) {
      if (day.weekday == date.weekday) return day;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'level': level,
    'weeks': weeks,
    'days': [for (final day in days) day.toJson()],
  };
}

class ActiveProgramEntry {
  const ActiveProgramEntry({
    required this.id,
    required this.name,
    required this.level,
    required this.startedAt,
    required this.totalWeeks,
    required this.daysPerWeek,
  });

  factory ActiveProgramEntry.fromJson(Map<String, dynamic> json) =>
      ActiveProgramEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        level: json['level'] as String? ?? '',
        startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
        totalWeeks: (json['totalWeeks'] as num? ?? 0).toInt(),
        daysPerWeek: (json['daysPerWeek'] as num? ?? 0).toInt(),
      );

  final String id;
  final String name;
  final String level;
  final DateTime startedAt;
  final int totalWeeks;
  final int daysPerWeek;

  int weekAt(DateTime date) {
    final start = AppDateUtils.startOfWeek(startedAt);
    final elapsed = AppDateUtils.daysBetween(
      start,
      AppDateUtils.startOfWeek(date),
    );
    final week = (elapsed ~/ DateTime.daysPerWeek) + 1;
    if (week < 1) return 1;
    return week > totalWeeks ? totalWeeks : week;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'startedAt': AppDateUtils.isoKey(startedAt),
    'totalWeeks': totalWeeks,
    'daysPerWeek': daysPerWeek,
  };
}

class WorkoutStateEntity {
  const WorkoutStateEntity({this.catalogVersion = 0, this.activeProgram});

  static const empty = WorkoutStateEntity();

  factory WorkoutStateEntity.fromJson(Map<String, dynamic> json) {
    final program = json['activeProgram'];
    return WorkoutStateEntity(
      catalogVersion: (json['catalogVersion'] as num? ?? 0).toInt(),
      activeProgram: program is Map<String, dynamic>
          ? ActiveProgramEntry.fromJson(program)
          : null,
    );
  }

  final int catalogVersion;
  final ActiveProgramEntry? activeProgram;

  Map<String, dynamic> toJson() => {
    'catalogVersion': catalogVersion,
    'activeProgram': activeProgram?.toJson(),
  };
}

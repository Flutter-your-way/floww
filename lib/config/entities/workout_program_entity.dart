import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/program_goal.dart';
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

  ProgramExerciseEntry copyWith({int? sets, int? reps}) => ProgramExerciseEntry(
    exerciseId: exerciseId,
    section: section,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    restSeconds: restSeconds,
    repsInReserve: repsInReserve,
    weightKg: weightKg,
  );

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

  ProgramDayEntry copyWith({
    int? weekday,
    String? name,
    String? focus,
    int? durationMinutes,
    List<ProgramExerciseEntry>? exercises,
  }) => ProgramDayEntry(
    weekday: weekday ?? this.weekday,
    name: name ?? this.name,
    focus: focus ?? this.focus,
    goal: goal,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    exercises: exercises ?? this.exercises,
  );

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
    this.deloadEvery = 0,
    this.goal = ProgramGoal.strength,
    this.isCustom = false,
    this.basedOn,
    this.lengthDays = 0,
    this.isGenerated = false,
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
        deloadEvery: (json['deloadEvery'] as num? ?? 0).toInt(),
        goal: ProgramGoal.fromId(json['goal'] as String?),
        isCustom: json['isCustom'] as bool? ?? false,
        basedOn: json['basedOn'] as String?,
        lengthDays: (json['lengthDays'] as num? ?? 0).toInt(),
        isGenerated: json['isGenerated'] as bool? ?? false,
      );

  final String id;
  final String name;
  final String description;
  final String level;
  final int weeks;
  final List<ProgramDayEntry> days;
  final int deloadEvery;
  final ProgramGoal goal;
  final bool isCustom;
  final String? basedOn;
  final int lengthDays;
  final bool isGenerated;

  static const String generatedName = 'Your Workout Plan';

  bool get hasFixedLength => lengthDays > 0;

  bool get needsGeneratedName => isGenerated && name != generatedName;

  bool isDeloadWeek(int week) => deloadEvery > 0 && week % deloadEvery == 0;

  int get sessionsPerWeek => days.length;

  Set<String> get exerciseIds => {
    for (final day in days)
      for (final exercise in day.exercises) exercise.exerciseId,
  };

  int get averageMinutes {
    if (days.isEmpty) return 0;
    var total = 0;
    for (final day in days) {
      total += day.durationMinutes;
    }
    return (total / days.length).round();
  }

  ProgramDayEntry? dayFor(DateTime date) {
    for (final day in days) {
      if (day.weekday == date.weekday) return day;
    }
    return null;
  }

  ProgramDayEntry? dayOn(DateTime date, List<int> weekdays) {
    if (weekdays.length != days.length) return dayFor(date);
    final index = weekdays.indexOf(date.weekday);
    return index < 0 ? null : days[index];
  }

  WorkoutProgramEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? level,
    int? weeks,
    List<ProgramDayEntry>? days,
    ProgramGoal? goal,
    bool? isCustom,
    String? basedOn,
  }) => WorkoutProgramEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    level: level ?? this.level,
    weeks: weeks ?? this.weeks,
    days: days ?? this.days,
    deloadEvery: deloadEvery,
    goal: goal ?? this.goal,
    isCustom: isCustom ?? this.isCustom,
    basedOn: basedOn ?? this.basedOn,
    lengthDays: lengthDays,
    isGenerated: isGenerated,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'level': level,
    'weeks': weeks,
    'days': [for (final day in days) day.toJson()],
    'deloadEvery': deloadEvery,
    'goal': goal.id,
    'isCustom': isCustom,
    if (basedOn != null) 'basedOn': basedOn,
    if (lengthDays > 0) 'lengthDays': lengthDays,
    if (isGenerated) 'isGenerated': isGenerated,
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
    this.shiftDays = 0,
    this.weekdays = const [],
    this.totalDays = 0,
  });

  factory ActiveProgramEntry.fromJson(Map<String, dynamic> json) =>
      ActiveProgramEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        level: json['level'] as String? ?? '',
        startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
        totalWeeks: (json['totalWeeks'] as num? ?? 0).toInt(),
        daysPerWeek: (json['daysPerWeek'] as num? ?? 0).toInt(),
        shiftDays: (json['shiftDays'] as num? ?? 0).toInt(),
        weekdays: [
          for (final item in (json['weekdays'] as List? ?? const []))
            if (item is num) item.toInt(),
        ],
        totalDays: (json['totalDays'] as num? ?? 0).toInt(),
      );

  final String id;
  final String name;
  final String level;
  final DateTime startedAt;
  final int totalWeeks;
  final int daysPerWeek;
  final int shiftDays;
  final List<int> weekdays;
  final int totalDays;

  bool get hasFixedLength => totalDays > 0;

  DateTime programDateOf(DateTime date) =>
      AppDateUtils.addDays(AppDateUtils.dateOnly(date), -shiftDays);

  ActiveProgramEntry shiftedBy(int days) => ActiveProgramEntry(
    id: id,
    name: name,
    level: level,
    startedAt: startedAt,
    totalWeeks: totalWeeks,
    daysPerWeek: daysPerWeek,
    shiftDays: shiftDays + days,
    weekdays: weekdays,
    totalDays: totalDays,
  );

  ActiveProgramEntry withProgram(WorkoutProgramEntity program) =>
      ActiveProgramEntry(
        id: id,
        name: program.name,
        level: program.level,
        startedAt: startedAt,
        totalWeeks: totalWeeks,
        daysPerWeek: program.sessionsPerWeek,
        shiftDays: shiftDays,
        weekdays: weekdays.length == program.days.length ? weekdays : const [],
        totalDays: totalDays,
      );

  DateTime get startDate => AppDateUtils.dateOnly(startedAt);

  DateTime get endDate => hasFixedLength
      ? AppDateUtils.addDays(startDate, totalDays)
      : AppDateUtils.addDays(
          AppDateUtils.startOfWeek(startedAt),
          totalWeeks * DateTime.daysPerWeek,
        );

  int dayNumberAt(DateTime date) {
    final day = AppDateUtils.daysBetween(startDate, programDateOf(date)) + 1;
    if (day < 1) return 1;
    return hasFixedLength && day > totalDays ? totalDays : day;
  }

  bool isActiveOn(DateTime date) {
    final programDate = programDateOf(date);
    if (programDate.isBefore(startDate)) return false;
    return totalWeeks <= 0 || programDate.isBefore(endDate);
  }

  int weekAt(DateTime date) {
    if (hasFixedLength) {
      return (dayNumberAt(date) - 1) ~/ DateTime.daysPerWeek + 1;
    }
    final start = AppDateUtils.startOfWeek(startedAt);
    final elapsed = AppDateUtils.daysBetween(
      start,
      AppDateUtils.startOfWeek(programDateOf(date)),
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
    'shiftDays': shiftDays,
    if (weekdays.isNotEmpty) 'weekdays': weekdays,
    if (totalDays > 0) 'totalDays': totalDays,
  };
}

class WorkoutStateEntity {
  const WorkoutStateEntity({
    this.catalogVersion = 0,
    this.activeProgram,
    this.generatedProgramId,
  });

  static const empty = WorkoutStateEntity();

  factory WorkoutStateEntity.fromJson(Map<String, dynamic> json) {
    final program = json['activeProgram'];
    return WorkoutStateEntity(
      catalogVersion: (json['catalogVersion'] as num? ?? 0).toInt(),
      activeProgram: program is Map<String, dynamic>
          ? ActiveProgramEntry.fromJson(program)
          : null,
      generatedProgramId: json['generatedProgramId'] as String?,
    );
  }

  final int catalogVersion;
  final ActiveProgramEntry? activeProgram;
  final String? generatedProgramId;

  bool get hasGeneratedPlan => generatedProgramId != null;

  Map<String, dynamic> toJson() => {
    'catalogVersion': catalogVersion,
    'activeProgram': activeProgram?.toJson(),
    if (generatedProgramId != null) 'generatedProgramId': generatedProgramId,
  };
}

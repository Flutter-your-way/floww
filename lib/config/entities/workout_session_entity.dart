import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/workout/models/workout_completion.dart';

enum WorkoutSessionStatus { inProgress, completed, abandoned }

class MuscleShareEntry {
  const MuscleShareEntry({required this.name, required this.share});

  factory MuscleShareEntry.fromJson(Map<String, dynamic> json) =>
      MuscleShareEntry(
        name: json['name'] as String? ?? '',
        share: (json['share'] as num? ?? 0).toDouble(),
      );

  final String name;
  final double share;

  Map<String, dynamic> toJson() => {'name': name, 'share': share};
}

class PersonalRecordEntry {
  const PersonalRecordEntry({
    required this.exerciseId,
    required this.exercise,
    required this.improvement,
    required this.glyph,
  });

  factory PersonalRecordEntry.fromJson(Map<String, dynamic> json) =>
      PersonalRecordEntry(
        exerciseId: json['exerciseId'] as String? ?? '',
        exercise: json['exercise'] as String? ?? '',
        improvement: json['improvement'] as String? ?? '',
        glyph: json['glyph'] as String? ?? '🏆',
      );

  final String exerciseId;
  final String exercise;
  final String improvement;
  final String glyph;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exercise': exercise,
    'improvement': improvement,
    'glyph': glyph,
  };
}

class WorkoutSessionEntity {
  const WorkoutSessionEntity({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.date,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.exercises,
    this.focus = '',
    this.goal = '',
    this.insight = '',
    this.programId,
    this.programLabel = '',
    this.caloriesKcal = 0,
    this.volumeKg = 0,
    this.totalSets = 0,
    this.totalReps = 0,
    this.exerciseCount = 0,
    this.trainingEffect = 0,
    this.flowPoints = 0,
    this.flowScoreBefore = 0,
    this.flowScoreAfter = 0,
    this.averageHeartRate,
    this.peakHeartRate,
    this.heartRateSamples = const [],
    this.muscleActivation = const [],
    this.personalRecords = const [],
    this.notes = '',
    this.recoveryMood,
    this.isTimerPaused = false,
    this.timerResumedAt,
    this.restEndsAt,
    this.restRemainingSeconds = 0,
    this.currentEntryId,
  });

  factory WorkoutSessionEntity.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionEntity(
        id: json['id'] as String,
        workoutId: json['workoutId'] as String? ?? json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        status: _statusOf(json['status'] as String?),
        startedAt: DateTime.parse(json['startedAt'] as String).toLocal(),
        completedAt: DateTime.parse(json['completedAt'] as String).toLocal(),
        durationSeconds: (json['durationSeconds'] as num? ?? 0).toInt(),
        exercises: WorkoutPlanEntity.entriesOf(json['exercises']),
        focus: json['focus'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
        insight: json['insight'] as String? ?? '',
        programId: json['programId'] as String?,
        programLabel: json['programLabel'] as String? ?? '',
        caloriesKcal: (json['caloriesKcal'] as num? ?? 0).toInt(),
        volumeKg: (json['volumeKg'] as num? ?? 0).toDouble(),
        totalSets: (json['totalSets'] as num? ?? 0).toInt(),
        totalReps: (json['totalReps'] as num? ?? 0).toInt(),
        exerciseCount: (json['exerciseCount'] as num? ?? 0).toInt(),
        trainingEffect: (json['trainingEffect'] as num? ?? 0).toDouble(),
        flowPoints: (json['flowPoints'] as num? ?? 0).toInt(),
        flowScoreBefore: (json['flowScoreBefore'] as num? ?? 0).toInt(),
        flowScoreAfter: (json['flowScoreAfter'] as num? ?? 0).toInt(),
        averageHeartRate: (json['averageHeartRate'] as num?)?.toInt(),
        peakHeartRate: (json['peakHeartRate'] as num?)?.toInt(),
        heartRateSamples: _samplesOf(json['heartRateSamples']),
        muscleActivation: _musclesOf(json['muscleActivation']),
        personalRecords: _recordsOf(json['personalRecords']),
        notes: json['notes'] as String? ?? '',
        recoveryMood: _moodOf(json['recoveryMood'] as String?),
        isTimerPaused: json['isTimerPaused'] as bool? ?? false,
        timerResumedAt: _dateOf(json['timerResumedAt']),
        restEndsAt: _dateOf(json['restEndsAt']),
        restRemainingSeconds: (json['restRemainingSeconds'] as num? ?? 0)
            .toInt(),
        currentEntryId: json['currentEntryId'] as String?,
      );

  final String id;
  final String workoutId;
  final String name;
  final DateTime date;
  final WorkoutSessionStatus status;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final List<WorkoutEntryEntity> exercises;
  final String focus;
  final String goal;
  final String insight;
  final String? programId;
  final String programLabel;
  final int caloriesKcal;
  final double volumeKg;
  final int totalSets;
  final int totalReps;
  final int exerciseCount;
  final double trainingEffect;
  final int flowPoints;
  final int flowScoreBefore;
  final int flowScoreAfter;
  final int? averageHeartRate;
  final int? peakHeartRate;
  final List<int> heartRateSamples;
  final List<MuscleShareEntry> muscleActivation;
  final List<PersonalRecordEntry> personalRecords;
  final String notes;
  final RecoveryMood? recoveryMood;
  final bool isTimerPaused;
  final DateTime? timerResumedAt;
  final DateTime? restEndsAt;
  final int restRemainingSeconds;
  final String? currentEntryId;

  bool get isCompleted => status == WorkoutSessionStatus.completed;

  bool get isInProgress => status == WorkoutSessionStatus.inProgress;

  bool get hasHeartRate => averageHeartRate != null;

  bool get isTimerRunning => isInProgress && !isTimerPaused;

  int elapsedSecondsAt(DateTime now) {
    final resumedAt = timerResumedAt;
    if (!isTimerRunning || resumedAt == null) return durationSeconds;
    final running = now.difference(resumedAt).inSeconds;
    return durationSeconds + (running < 0 ? 0 : running);
  }

  WorkoutSessionEntity withPlannedSetsLogged(DateTime now) => copyWith(
    exercises: [
      for (final entry in exercises) entry.withPlannedSetsLogged(now),
    ],
  );

  int restSecondsAt(DateTime now) {
    if (isTimerPaused) return restRemainingSeconds;
    final endsAt = restEndsAt;
    if (endsAt == null) return 0;
    final remaining = (endsAt.difference(now).inMilliseconds / 1000).ceil();
    return remaining < 0 ? 0 : remaining;
  }

  WorkoutSessionEntity restingFor(int seconds, DateTime now) => seconds <= 0
      ? copyWith(clearRest: true)
      : isTimerPaused
      ? copyWith(restRemainingSeconds: seconds, clearRestEnd: true)
      : copyWith(
          restEndsAt: now.add(Duration(seconds: seconds)),
          restRemainingSeconds: 0,
        );

  WorkoutSessionEntity pausedAt(DateTime now) => isTimerRunning
      ? copyWith(
          durationSeconds: elapsedSecondsAt(now),
          isTimerPaused: true,
          restRemainingSeconds: restSecondsAt(now),
          clearRestEnd: true,
        )
      : this;

  WorkoutSessionEntity resumedAt(DateTime now) {
    final rest = restSecondsAt(now);
    final resumed = copyWith(
      isTimerPaused: false,
      timerResumedAt: now,
      clearRest: true,
    );
    return rest <= 0 ? resumed : resumed.restingFor(rest, now);
  }

  int get plannedSets {
    var count = 0;
    for (final exercise in exercises) {
      count += exercise.targetSets;
    }
    return count;
  }

  WorkoutSessionEntity copyWith({
    WorkoutSessionStatus? status,
    DateTime? completedAt,
    int? durationSeconds,
    List<WorkoutEntryEntity>? exercises,
    String? notes,
    RecoveryMood? recoveryMood,
    bool? isTimerPaused,
    DateTime? timerResumedAt,
    DateTime? restEndsAt,
    int? restRemainingSeconds,
    String? currentEntryId,
    bool clearRest = false,
    bool clearRestEnd = false,
    bool clearCurrentEntry = false,
  }) => WorkoutSessionEntity(
    id: id,
    workoutId: workoutId,
    name: name,
    date: date,
    status: status ?? this.status,
    startedAt: startedAt,
    completedAt: completedAt ?? this.completedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    exercises: exercises ?? this.exercises,
    focus: focus,
    goal: goal,
    insight: insight,
    programId: programId,
    programLabel: programLabel,
    caloriesKcal: caloriesKcal,
    volumeKg: volumeKg,
    totalSets: totalSets,
    totalReps: totalReps,
    exerciseCount: exerciseCount,
    trainingEffect: trainingEffect,
    flowPoints: flowPoints,
    flowScoreBefore: flowScoreBefore,
    flowScoreAfter: flowScoreAfter,
    averageHeartRate: averageHeartRate,
    peakHeartRate: peakHeartRate,
    heartRateSamples: heartRateSamples,
    muscleActivation: muscleActivation,
    personalRecords: personalRecords,
    notes: notes ?? this.notes,
    recoveryMood: recoveryMood ?? this.recoveryMood,
    isTimerPaused: isTimerPaused ?? this.isTimerPaused,
    timerResumedAt: timerResumedAt ?? this.timerResumedAt,
    restEndsAt: clearRest || clearRestEnd
        ? null
        : restEndsAt ?? this.restEndsAt,
    restRemainingSeconds: clearRest
        ? 0
        : restRemainingSeconds ?? this.restRemainingSeconds,
    currentEntryId: clearCurrentEntry
        ? null
        : currentEntryId ?? this.currentEntryId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'name': name,
    'date': AppDateUtils.dateKey(date),
    'status': status.name,
    'startedAt': AppDateUtils.isoKey(startedAt),
    'completedAt': AppDateUtils.isoKey(completedAt),
    'exercises': [for (final exercise in exercises) exercise.toJson()],
    'focus': focus,
    'goal': goal,
    'insight': insight,
    if (programId != null) 'programId': programId,
    'programLabel': programLabel,
    'caloriesKcal': caloriesKcal,
    'volumeKg': volumeKg,
    'totalSets': totalSets,
    'totalReps': totalReps,
    'exerciseCount': exerciseCount,
    'trainingEffect': trainingEffect,
    'flowPoints': flowPoints,
    'flowScoreBefore': flowScoreBefore,
    'flowScoreAfter': flowScoreAfter,
    if (averageHeartRate != null) 'averageHeartRate': averageHeartRate,
    if (peakHeartRate != null) 'peakHeartRate': peakHeartRate,
    'heartRateSamples': heartRateSamples,
    'muscleActivation': [
      for (final muscle in muscleActivation) muscle.toJson(),
    ],
    'personalRecords': [for (final record in personalRecords) record.toJson()],
    'notes': notes,
    if (recoveryMood != null) 'recoveryMood': recoveryMood!.name,
    ...timerJson,
  };

  Map<String, dynamic> get timerJson => {
    'durationSeconds': durationSeconds,
    'isTimerPaused': isTimerPaused,
    if (timerResumedAt != null)
      'timerResumedAt': AppDateUtils.isoKey(timerResumedAt!),
    ...restJson,
  };

  Map<String, dynamic> get restJson => {
    'restEndsAt': restEndsAt == null ? null : AppDateUtils.isoKey(restEndsAt!),
    'restRemainingSeconds': restRemainingSeconds,
    'currentEntryId': currentEntryId,
  };

  static DateTime? _dateOf(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static WorkoutSessionStatus _statusOf(String? value) =>
      WorkoutSessionStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => WorkoutSessionStatus.inProgress,
      );

  static RecoveryMood? _moodOf(String? value) {
    if (value == null) return null;
    for (final mood in RecoveryMood.values) {
      if (mood.name == value) return mood;
    }
    return null;
  }

  static List<int> _samplesOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is num) item.toInt(),
    ];
  }

  static List<MuscleShareEntry> _musclesOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) MuscleShareEntry.fromJson(item),
    ];
  }

  static List<PersonalRecordEntry> _recordsOf(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map<String, dynamic>) PersonalRecordEntry.fromJson(item),
    ];
  }
}

import 'package:floww/core/workout/models/today_workout.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_detail.dart';
import 'package:floww/core/workout/models/workout_program.dart';
import 'package:floww/core/workout/models/workout_session.dart';
import 'package:floww/core/workout/models/workout_suggestion.dart';
import 'package:floww/core/workout/services/today_workout_data.dart';

class WorkoutService {
  const WorkoutService();

  TodayWorkout todayWorkout() => TodayWorkoutData.legDay;

  static const _completedSession = WorkoutSession(
    name: 'Leg Day',
    exerciseCount: 6,
    flowPoints: 8,
    isCompleted: true,
    durationSeconds: 2900,
    volumeKg: 12450,
    calories: 642,
    averageHeartRate: 136,
    peakHeartRate: 168,
    heartRateZone: 3,
    heartRateZoneCount: 5,
    heartRateSamples: [78, 104, 132, 142, 145, 143, 148, 152, 149, 147, 118],
    trainingEffect: 4.2,
    trainingEffectRating: 'Great',
    trainingEffectSummary:
        'This workout improved your strength and muscular endurance.',
    trainingEffectScale: 7,
    recoveryHours: 24,
    muscleRecoveryMinHours: 48,
    muscleRecoveryMaxHours: 72,
    muscleActivation: [
      MuscleActivation(name: 'Quadriceps', share: 0.85),
      MuscleActivation(name: 'Hamstrings', share: 0.78),
      MuscleActivation(name: 'Glutes', share: 0.72),
      MuscleActivation(name: 'Calves', share: 0.46),
    ],
    newPersonalRecords: 2,
    exercisesCompleted: 6,
    totalSets: 18,
    totalReps: 162,
    personalRecords: [
      PersonalRecord(glyph: '🏋️', exercise: 'Bench', improvement: '+5kg'),
      PersonalRecord(glyph: '🦵', exercise: 'Squat', improvement: '+2 reps'),
    ],
  );

  WorkoutSession? completedSessionFor(DateTime date) => _completedSession;

  static const _completion = WorkoutCompletion(
    workoutId: 'leg-day-today',
    name: 'Push Day',
    modeLabel: 'FLOW MODE',
    durationSeconds: 3000,
    calories: 642,
    volumeKg: 13300,
    personalRecords: 3,
    flowScoreBefore: 74,
    flowScoreAfter: 81,
    headline: 'Absolute machine! 💪',
    caption: 'That\'s next-level lifting.',
    muscleTags: ['Chest', 'Quadriceps', 'Shoulders'],
    siteLabel: 'flowwapp.com',
    handleLabel: '@flowwapp_',
  );

  WorkoutCompletion completionFor(String workoutId) => _completion;

  Future<void> saveRecoveryCheckIn({
    required String workoutId,
    required RecoveryMood mood,
  }) async {}

  static const _warmUpSection = WorkoutSectionGroup(
    id: 'warm-up',
    glyph: '🔥',
    title: 'Warm Up',
    status: WorkoutSectionStatus.completed,
    exercises: [
      WorkoutExercise(
        id: 'bodyweight-squat',
        name: 'Bodyweight Squat',
        sets: 2,
        reps: 15,
        restSeconds: 45,
      ),
      WorkoutExercise(
        id: 'hip-flexor-stretch',
        name: 'Hip Flexor Stretch',
        sets: 2,
        reps: 30,
        restSeconds: 30,
      ),
    ],
  );

  static const _mainSection = WorkoutSectionGroup(
    id: 'main-exercises',
    glyph: '⚡',
    title: 'Main Exercises',
    status: WorkoutSectionStatus.active,
    exercises: [
      WorkoutExercise(
        id: 'barbell-back-squat',
        name: 'Barbell Back Squat',
        sets: 4,
        reps: 8,
        restSeconds: 120,
        weightKg: 100,
      ),
      WorkoutExercise(
        id: 'romanian-deadlift',
        name: 'Romanian Deadlift',
        sets: 4,
        reps: 10,
        restSeconds: 90,
        weightKg: 80,
      ),
      WorkoutExercise(
        id: 'leg-press',
        name: 'Leg Press',
        sets: 3,
        reps: 12,
        restSeconds: 90,
        weightKg: 140,
      ),
      WorkoutExercise(
        id: 'walking-lunge',
        name: 'Walking Lunge',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        weightKg: 20,
      ),
    ],
  );

  static const _coolDownSection = WorkoutSectionGroup(
    id: 'cool-down',
    glyph: '🌊',
    title: 'Cool Down',
    status: WorkoutSectionStatus.pending,
    exercises: [
      WorkoutExercise(
        id: 'hamstring-stretch',
        name: 'Hamstring Stretch',
        sets: 2,
        reps: 30,
        restSeconds: 30,
      ),
      WorkoutExercise(
        id: 'quad-stretch',
        name: 'Quad Stretch',
        sets: 2,
        reps: 30,
        restSeconds: 30,
      ),
      WorkoutExercise(
        id: 'calf-stretch',
        name: 'Calf Stretch',
        sets: 2,
        reps: 30,
        restSeconds: 30,
      ),
      WorkoutExercise(
        id: 'foam-roll',
        name: 'Foam Roll Quads',
        sets: 2,
        reps: 45,
        restSeconds: 30,
      ),
    ],
  );

  WorkoutDetail? detailFor(String id) {
    final entry = _historyEntryFor(id);
    if (entry == null) return null;
    return WorkoutDetail(
      id: entry.id,
      name: entry.name,
      performedAt: entry.performedAt,
      isCompleted: entry.isCompleted,
      durationSeconds: _completedSession.durationSeconds,
      volumeKg: _completedSession.volumeKg,
      calories: _completedSession.calories,
      averageHeartRate: _completedSession.averageHeartRate,
      sections: const [_warmUpSection, _mainSection, _coolDownSection],
      insight: 'Your squat volume increased 8%. Excellent progression.',
      notes:
          'Felt strong today. Increased weight on squats and RDLs. Good depth '
          'and control on all movements.',
    );
  }

  WorkoutHistoryEntry? _historyEntryFor(String id) {
    for (final entry in loadHistoryFor(DateTime.now())) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  List<WorkoutHistoryEntry> loadHistoryFor(DateTime date) => [
    WorkoutHistoryEntry(
      id: 'leg-day-today',
      name: 'Leg Day',
      performedAt: DateTime(date.year, date.month, date.day, 20, 30),
      durationSeconds: 3130,
      calories: 385,
      exerciseCount: 6,
      trainingEffect: 4.2,
      isCompleted: true,
    ),
    WorkoutHistoryEntry(
      id: 'pull-day-16',
      name: 'Pull Day',
      performedAt: DateTime(date.year, 7, 16, 19, 15),
      durationSeconds: 2730,
      calories: 410,
      exerciseCount: 5,
      trainingEffect: 3.8,
      isCompleted: false,
    ),
    WorkoutHistoryEntry(
      id: 'pull-day-16-b',
      name: 'Pull Day',
      performedAt: DateTime(date.year, 7, 16, 7, 40),
      durationSeconds: 2730,
      calories: 410,
      exerciseCount: 5,
      trainingEffect: 3.8,
      isCompleted: false,
    ),
    WorkoutHistoryEntry(
      id: 'leg-day-18',
      name: 'Leg Day',
      performedAt: DateTime(date.year, 7, 18, 18, 5),
      durationSeconds: 3020,
      calories: 520,
      exerciseCount: 6,
      trainingEffect: 4.2,
      isCompleted: false,
    ),
  ];

  static const _suggestion = WorkoutSuggestion(
    title: 'Pull Day: Chest, Shoulders & Triceps',
    durationMinutes: 60,
    intensity: 'High Intensity',
    reasons: ['Recovery is High', 'Last workout 48h ago', 'FLOW mode active'],
  );

  static const _programs = [
    WorkoutProgram(
      id: 'fat-loss-shred',
      name: 'Fat Loss Shred',
      description: 'High-intensity metabolic conditioning',
      level: 'Intermediate',
      weeks: 8,
      sessionsPerWeek: 5,
    ),
    WorkoutProgram(
      id: 'muscle-hypertrophy',
      name: 'Muscle Hypertrophy',
      description: 'Volume-focused strength and size work',
      level: 'Advanced',
      weeks: 16,
      sessionsPerWeek: 5,
    ),
    WorkoutProgram(
      id: 'cardio-base',
      name: 'Cardio Base',
      description: 'Low-intensity aerobic base building',
      level: 'All Levels',
      weeks: 6,
      sessionsPerWeek: 3,
    ),
  ];

  static const _activeProgram = ActiveProgram(
    id: 'strength-builder',
    name: 'Strength Builder',
    level: 'Intermediate',
    currentWeek: 4,
    totalWeeks: 12,
    daysPerWeek: 4,
  );

  ActiveProgram? loadActiveProgram() => _activeProgram;

  WorkoutProgram? programById(String id) {
    for (final program in _programs) {
      if (program.id == id) return program;
    }
    return null;
  }

  WorkoutSuggestion? suggestionFor(DateTime date) => _suggestion;

  List<WorkoutProgram> loadPrograms() => _programs;
}

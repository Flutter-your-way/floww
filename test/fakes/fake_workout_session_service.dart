import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class FakeWorkoutSessionService implements WorkoutSessionService {
  FakeWorkoutSessionService(this.session);

  final WorkoutSessionEntity session;

  @override
  Stream<WorkoutSessionEntity?> watchSession(String id) =>
      Stream.value(session);

  @override
  Future<List<WorkoutSessionEntity>> loadRecentSessions() async => [session];

  @override
  Future<void> updateNotes(String id, String notes) async {}

  @override
  Future<void> saveRecoveryMood(String id, RecoveryMood mood) async {}

  @override
  Future<void> addExercise(String id, WorkoutEntryEntity entry) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class WorkoutFixtures {
  WorkoutFixtures._();

  static WorkoutEntryEntity entry({
    required String id,
    required String name,
    required WorkoutSectionKind section,
    int sets = 4,
    int reps = 8,
    double? weightKg = 60,
    int loggedSets = 4,
  }) => WorkoutEntryEntity(
    id: id,
    exerciseId: id,
    name: name,
    section: section,
    targetSets: sets,
    targetReps: reps,
    restSeconds: 120,
    repsInReserve: 2,
    met: 6,
    muscleShares: const {'Quadriceps': 1, 'Glutes': 0.8},
    targetWeightKg: weightKg,
    guidelines: const [ExerciseCueEntry(text: 'Brace the core')],
    sets: [
      for (var index = 0; index < loggedSets; index++)
        LoggedSetEntry(
          reps: reps,
          loggedAt: DateTime(2026, 9, 16, 20, 30 + index),
          weightKg: weightKg,
        ),
    ],
  );

  static WorkoutSessionEntity session() {
    final exercises = [
      entry(
        id: 'barbell-back-squat',
        name: 'Barbell Back Squat',
        section: WorkoutSectionKind.main,
      ),
      entry(
        id: 'romanian-deadlift',
        name: 'Romanian Deadlift',
        section: WorkoutSectionKind.main,
        reps: 12,
        weightKg: 50,
      ),
      entry(
        id: 'hamstring-stretch',
        name: 'Hamstring Stretch',
        section: WorkoutSectionKind.coolDown,
        sets: 2,
        reps: 30,
        weightKg: null,
        loggedSets: 2,
      ),
    ];

    return WorkoutSessionEntity(
      id: 'session-1',
      workoutId: 'strength-builder-2026-09-16',
      name: 'Leg Day',
      date: DateTime(2026, 9, 16),
      status: WorkoutSessionStatus.completed,
      startedAt: DateTime(2026, 9, 16, 20, 30),
      completedAt: DateTime(2026, 9, 16, 21, 18),
      durationSeconds: 2900,
      exercises: exercises,
      focus: 'Strength',
      goal: 'Increase squat weight.',
      programLabel: 'Strength Builder Program · Week 4',
      caloriesKcal: 642,
      volumeKg: 12450,
      totalSets: 10,
      totalReps: 140,
      exerciseCount: 3,
      trainingEffect: 4.2,
      flowPoints: 8,
      flowScoreBefore: 74,
      flowScoreAfter: 82,
      averageHeartRate: 136,
      peakHeartRate: 168,
      heartRateSamples: const [78, 104, 132, 142, 145, 143, 148, 152, 149],
      muscleActivation: const [
        MuscleShareEntry(name: 'Quadriceps', share: 0.85),
        MuscleShareEntry(name: 'Glutes', share: 0.72),
      ],
      personalRecords: const [
        PersonalRecordEntry(
          exerciseId: 'barbell-back-squat',
          exercise: 'Barbell Back Squat',
          improvement: '+5kg',
          glyph: '🏋️',
        ),
      ],
      notes: 'Felt strong today. Good depth and control on all movements.',
    );
  }
}

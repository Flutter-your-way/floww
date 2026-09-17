import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';

class WorkoutPlanService extends WorkoutFirestore {
  WorkoutPlanService(this._catalogService);

  static const String _loadFailure = 'Could not load your planned workout.';
  static const String _saveFailure =
      'Could not update this workout. Please try again.';
  static const int _scheduleAheadDays = 28;

  final WorkoutCatalogService _catalogService;

  CollectionReference<Map<String, dynamic>> _plans(String uid) =>
      collectionOf(uid, AppCollection.workoutPlans);

  Stream<WorkoutPlanEntity?> watchPlan(DateTime date) {
    final uid = userId;
    if (uid == null) return Stream.value(null);
    return _plans(uid).doc(AppDateUtils.dateKey(date)).snapshots().map((
      document,
    ) {
      final data = document.data();
      return data == null ? null : WorkoutPlanEntity.fromJson(data);
    });
  }

  Future<WorkoutPlanEntity?> loadPlan(DateTime date) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('loadPlan', _loadFailure, () async {
      final document = await _plans(uid).doc(AppDateUtils.dateKey(date)).get();
      final data = document.data();
      return data == null ? null : WorkoutPlanEntity.fromJson(data);
    });
  }

  Future<WorkoutPlanEntity?> nextPlanAfter(DateTime date) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('nextPlanAfter', _loadFailure, () async {
      final snapshot = await _plans(uid)
          .orderBy(FieldPath.documentId)
          .startAfter([AppDateUtils.dateKey(date)])
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return WorkoutPlanEntity.fromJson(snapshot.docs.first.data());
    });
  }

  Future<void> savePlan(WorkoutPlanEntity plan) async {
    final uid = requireUserId;
    await guard(
      'savePlan',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(plan.date)).set(plan.toJson()),
    );
  }

  Future<void> linkSession(DateTime date, String sessionId) async {
    final uid = requireUserId;
    await guard(
      'linkSession',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(date)).set({
        'sessionId': sessionId,
      }, SetOptions(merge: true)),
    );
  }

  Future<WorkoutPlanEntity?> ensurePlanFor(
    DateTime date, {
    required ActiveProgramEntry? activeProgram,
  }) async {
    final existing = await loadPlan(date);
    if (existing != null) return existing;
    if (activeProgram == null) return null;

    final program = await _catalogService.programById(activeProgram.id);
    if (program == null) return null;

    final plan = await buildPlan(
      date: date,
      program: program,
      activeProgram: activeProgram,
    );
    if (plan == null) return null;
    await savePlan(plan);
    return plan;
  }

  Future<void> scheduleProgram(
    WorkoutProgramEntity program,
    ActiveProgramEntry activeProgram,
  ) async {
    final uid = requireUserId;
    final today = AppDateUtils.dateOnly(DateTime.now());
    final catalog = await _catalogMap();

    await guard('scheduleProgram', _saveFailure, () async {
      final batch = firestore.batch();
      for (var offset = 0; offset < _scheduleAheadDays; offset++) {
        final date = AppDateUtils.addDays(today, offset);
        final plan = _planOf(
          date: date,
          program: program,
          activeProgram: activeProgram,
          catalog: catalog,
        );
        final document = _plans(uid).doc(AppDateUtils.dateKey(date));
        if (plan == null) {
          batch.delete(document);
        } else {
          batch.set(document, plan.toJson());
        }
      }
      await batch.commit();
    });
  }

  Future<WorkoutPlanEntity?> buildPlan({
    required DateTime date,
    required WorkoutProgramEntity program,
    required ActiveProgramEntry activeProgram,
  }) async => _planOf(
    date: date,
    program: program,
    activeProgram: activeProgram,
    catalog: await _catalogMap(),
  );

  Future<Map<String, ExerciseCatalogEntry>> _catalogMap() async {
    final exercises = await _catalogService.loadExercises();
    return {for (final exercise in exercises) exercise.id: exercise};
  }

  WorkoutPlanEntity? _planOf({
    required DateTime date,
    required WorkoutProgramEntity program,
    required ActiveProgramEntry activeProgram,
    required Map<String, ExerciseCatalogEntry> catalog,
  }) {
    final day = program.dayFor(date);
    if (day == null) return null;

    final entries = <WorkoutEntryEntity>[];
    for (var index = 0; index < day.exercises.length; index++) {
      final planned = day.exercises[index];
      final exercise = catalog[planned.exerciseId];
      if (exercise == null) continue;
      entries.add(
        WorkoutEntryEntity.fromCatalog(
          exercise,
          id: '${planned.exerciseId}-$index',
          section: planned.section,
          sets: planned.sets,
          reps: planned.reps,
          restSeconds: planned.restSeconds,
          repsInReserve: planned.repsInReserve,
          weightKg: planned.weightKg,
        ),
      );
    }
    if (entries.isEmpty) return null;

    final week = activeProgram.weekAt(date);
    return WorkoutPlanEntity(
      id: '${program.id}-${AppDateUtils.dateKey(date)}',
      date: AppDateUtils.dateOnly(date),
      name: day.name,
      focus: day.focus,
      goal: day.goal,
      insight: _insightOf(program: program, day: day, week: week),
      durationMinutes: day.durationMinutes,
      exercises: entries,
      programId: program.id,
      programLabel: '${program.name} Program · Week $week',
    );
  }

  String _insightOf({
    required WorkoutProgramEntity program,
    required ProgramDayEntry day,
    required int week,
  }) =>
      'WAVE scheduled ${day.name} from your ${program.name} program, week '
      '$week of ${program.weeks}. Focus on ${day.focus.toLowerCase()} and '
      'keep the target reps in reserve on every set.';

  WorkoutEntryEntity entryFrom(
    ExerciseCatalogEntry exercise, {
    required WorkoutSectionKind section,
    int? sets,
    int? reps,
    int? restSeconds,
    double? weightKg,
  }) => WorkoutEntryEntity.fromCatalog(
    exercise,
    id: '${exercise.id}-${DateTime.now().microsecondsSinceEpoch}',
    section: section,
    sets: sets,
    reps: reps,
    restSeconds: restSeconds,
    weightKg: weightKg,
  );
}

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/workout_exercise_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floww/core/workout/models/program_phase.dart';
import 'package:floww/core/workout/models/workout_section_kind.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_progression.dart';
import 'package:floww/core/workout/services/workout_readiness_service.dart';

class WorkoutPlanService extends WorkoutFirestore {
  WorkoutPlanService(this._catalogService);

  static const String _loadFailure = 'Could not load your planned workout.';
  static const String _saveFailure =
      'Could not update this workout. Please try again.';
  static const int _scheduleAheadDays = 28;
  static const String _restField = 'isRest';
  static const String _idField = 'id';
  static const String _movedToField = 'movedTo';
  static const String _sessionField = 'sessionId';
  static const int _minAdaptedSets = 1;
  static const int _maxInsightReasons = 3;
  static const int _maxAlternatives = 8;
  static const double _sameGroupBonus = 0.5;
  static const double _savedBonus = 0.25;
  static const double _defaultWeightStepKg = 2.5;

  final WorkoutCatalogService _catalogService;

  CollectionReference<Map<String, dynamic>> _plans(String uid) =>
      collectionOf(uid, AppCollection.workoutPlans);

  Stream<List<WorkoutPlanEntity>> watchCatchUps(DateTime date) {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _plans(uid)
        .where(
          WorkoutPlanEntity.rescheduledToField,
          isEqualTo: AppDateUtils.dateKey(date),
        )
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              if (_storedPlanOf(doc.data()) case final plan?)
                if (!AppDateUtils.isSameDay(plan.date, date)) plan,
          ]..sort((a, b) => a.date.compareTo(b.date)),
        );
  }

  Future<void> scheduleCatchUp(WorkoutPlanEntity missed, DateTime day) async {
    final uid = requireUserId;
    await guard(
      'scheduleCatchUp',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(missed.date)).set({
        WorkoutPlanEntity.rescheduledToField: AppDateUtils.dateKey(day),
      }, SetOptions(merge: true)),
    );
  }

  Future<void> unscheduleCatchUp(WorkoutPlanEntity missed) async {
    final uid = requireUserId;
    await guard(
      'unscheduleCatchUp',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(missed.date)).set({
        WorkoutPlanEntity.rescheduledToField: FieldValue.delete(),
      }, SetOptions(merge: true)),
    );
  }

  Stream<WorkoutPlanEntity?> watchPlan(DateTime date) {
    final uid = userId;
    if (uid == null) return Stream.value(null);
    return _plans(uid).doc(AppDateUtils.dateKey(date)).snapshots().map((
      document,
    ) {
      return _storedPlanOf(document.data());
    });
  }

  static WorkoutPlanEntity? _storedPlanOf(Map<String, dynamic>? data) {
    if (data == null || data[_restField] == true) return null;
    return WorkoutPlanEntity.fromJson(data);
  }

  Future<Map<String, dynamic>?> _documentOf(DateTime date) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('loadPlan', _loadFailure, () async {
      final document = await _plans(uid).doc(AppDateUtils.dateKey(date)).get();
      return document.data();
    });
  }

  Future<WorkoutPlanEntity?> loadPlan(DateTime date) async =>
      _storedPlanOf(await _documentOf(date));

  Future<WorkoutPlanEntity?> nextPlanAfter(DateTime date) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('nextPlanAfter', _loadFailure, () async {
      final snapshot = await _plans(uid)
          .orderBy(FieldPath.documentId)
          .startAfter([AppDateUtils.dateKey(date)])
          .limit(DateTime.daysPerWeek)
          .get();
      for (final doc in snapshot.docs) {
        final plan = _storedPlanOf(doc.data());
        if (plan != null) return plan;
      }
      return null;
    });
  }

  Future<List<WorkoutPlanEntity>> loadScheduleBetween(
    DateTime start,
    DateTime end, {
    required ActiveProgramEntry? activeProgram,
  }) async {
    final uid = userId;
    if (uid == null) return const [];
    final stored = await guard('loadSchedule', _loadFailure, () async {
      final snapshot = await _plans(uid)
          .orderBy(FieldPath.documentId)
          .startAt([AppDateUtils.dateKey(start)])
          .endBefore([AppDateUtils.dateKey(end)])
          .get();
      return {for (final doc in snapshot.docs) doc.id: doc.data()};
    });

    final program = activeProgram == null
        ? null
        : await _catalogService.programById(activeProgram.id);
    final catalog = program == null
        ? const <String, ExerciseCatalogEntry>{}
        : await _catalogMap();
    final programStart = activeProgram == null
        ? null
        : AppDateUtils.dateOnly(activeProgram.startedAt);

    final plans = <WorkoutPlanEntity>[];
    for (
      var date = AppDateUtils.dateOnly(start);
      date.isBefore(end);
      date = AppDateUtils.addDays(date, 1)
    ) {
      final document = stored[AppDateUtils.dateKey(date)];
      if (document != null) {
        final plan = document[_idField] == null
            ? null
            : _storedPlanOf(document);
        if (plan != null) plans.add(plan);
        continue;
      }
      if (program == null ||
          activeProgram == null ||
          programStart == null ||
          date.isBefore(programStart)) {
        continue;
      }
      final plan = _planOf(
        date: date,
        program: program,
        activeProgram: activeProgram,
        catalog: catalog,
      );
      if (plan != null) plans.add(plan);
    }
    return plans;
  }

  Future<void> savePlan(WorkoutPlanEntity plan) async {
    final uid = requireUserId;
    await guard('savePlan', _saveFailure, () {
      final batch = firestore.batch();
      batch.set(_plans(uid).doc(AppDateUtils.dateKey(plan.date)), plan.toJson());
      _catalogService.unlockInto(batch, uid, [
        for (final entry in plan.exercises) entry.exerciseId,
      ]);
      return batch.commit();
    });
  }

  Future<void> linkSession(DateTime date, String sessionId) async {
    final uid = requireUserId;
    await guard(
      'linkSession',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(date)).set({
        _sessionField: sessionId,
      }, SetOptions(merge: true)),
    );
  }

  Future<void> unlinkSession(DateTime date) async {
    final uid = requireUserId;
    await guard(
      'unlinkSession',
      _saveFailure,
      () => _plans(uid).doc(AppDateUtils.dateKey(date)).set({
        _sessionField: FieldValue.delete(),
      }, SetOptions(merge: true)),
    );
  }

  Future<WorkoutPlanEntity?> ensurePlanFor(
    DateTime date, {
    required ActiveProgramEntry? activeProgram,
  }) async {
    final document = await _documentOf(date);
    if (document != null) return _storedPlanOf(document);
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
    ActiveProgramEntry activeProgram, {
    DateTime? from,
    bool saveActive = false,
  }) async {
    final uid = requireUserId;
    final start = AppDateUtils.dateOnly(from ?? DateTime.now());

    await guard('scheduleProgram', _saveFailure, () async {
      final batch = firestore.batch();
      await _scheduleInto(batch, uid, program, activeProgram, start);
      if (saveActive) _setActive(batch, uid, activeProgram);
      await batch.commit();
    });
  }

  Future<void> _scheduleInto(
    WriteBatch batch,
    String uid,
    WorkoutProgramEntity program,
    ActiveProgramEntry activeProgram,
    DateTime start,
  ) async {
    final aheadDays = activeProgram.totalDays > _scheduleAheadDays
        ? activeProgram.totalDays
        : _scheduleAheadDays;
    final end = AppDateUtils.addDays(start, aheadDays);
    final catalog = await _catalogMap();
    final existing = await _plans(uid)
        .orderBy(FieldPath.documentId)
        .startAt([AppDateUtils.dateKey(start)])
        .endBefore([AppDateUtils.dateKey(end)])
        .get();
    final started = {
      for (final doc in existing.docs)
        if (doc.data()[_sessionField] != null) doc.id,
    };
    for (var offset = 0; offset < aheadDays; offset++) {
      final date = AppDateUtils.addDays(start, offset);
      final key = AppDateUtils.dateKey(date);
      if (started.contains(key)) continue;
      final plan = _planOf(
        date: date,
        program: program,
        activeProgram: activeProgram,
        catalog: catalog,
      );
      final document = _plans(uid).doc(key);
      if (plan == null) {
        batch.delete(document);
      } else {
        batch.set(document, plan.toJson());
      }
    }
    _catalogService.unlockInto(batch, uid, [
      for (final id in program.exerciseIds)
        if (catalog[id]?.isAvailable == false) id,
    ]);
  }

  void _setActive(WriteBatch batch, String uid, ActiveProgramEntry? active) =>
      batch.set(stateDoc(uid), {
        'activeProgram': active?.toJson(),
      }, SetOptions(merge: true));

  Future<void> clearUpcoming(DateTime from, {bool stopProgram = false}) async {
    final uid = requireUserId;
    await guard('clearUpcoming', _saveFailure, () async {
      final upcoming = await _plans(uid).orderBy(FieldPath.documentId).startAt([
        AppDateUtils.dateKey(from),
      ]).get();
      final batch = firestore.batch();
      for (final doc in upcoming.docs) {
        if (doc.data()[_sessionField] == null) batch.delete(doc.reference);
      }
      if (stopProgram) _setActive(batch, uid, null);
      await batch.commit();
    });
  }

  Future<void> shiftToToday({
    required DateTime today,
    required ActiveProgramEntry shifted,
  }) async {
    final uid = requireUserId;
    final tomorrow = AppDateUtils.addDays(today, 1);
    final tomorrowKey = AppDateUtils.dateKey(tomorrow);
    final program = await _catalogService.programById(shifted.id);
    await guard('shiftToToday', _saveFailure, () async {
      final batch = firestore.batch();
      if (program != null) {
        await _scheduleInto(batch, uid, program, shifted, tomorrow);
      }
      _setActive(batch, uid, shifted);
      batch.set(_plans(uid).doc(AppDateUtils.dateKey(today)), {
        ..._restOf(today),
        _movedToField: tomorrowKey,
      });
      await batch.commit();
    });
  }

  Future<WorkoutPlanEntity?> postponedPlanOf(DateTime date) async {
    final document = await _documentOf(date);
    if (document == null || document[_restField] != true) return null;
    final movedTo = document[_movedToField];
    final target = movedTo is String
        ? DateTime.parse(movedTo)
        : AppDateUtils.addDays(date, 1);
    final plan = await loadPlan(target);
    if (plan == null || plan.sessionId != null) return null;
    return plan;
  }

  Future<void> restoreToToday({
    required DateTime today,
    required ActiveProgramEntry restored,
    required WorkoutPlanEntity postponed,
  }) async {
    final uid = requireUserId;
    final program = await _catalogService.programById(restored.id);
    await guard('restoreToToday', _saveFailure, () async {
      final batch = firestore.batch();
      if (program != null) {
        await _scheduleInto(
          batch,
          uid,
          program,
          restored,
          AppDateUtils.addDays(today, 1),
        );
      }
      _setActive(batch, uid, restored);
      batch.set(
        _plans(uid).doc(AppDateUtils.dateKey(today)),
        postponed
            .copyWith(date: AppDateUtils.dateOnly(today), isAdapted: false)
            .toJson(),
      );
      await batch.commit();
    });
  }

  Map<String, dynamic> _restOf(DateTime date) => {
    'date': AppDateUtils.dateKey(date),
    _restField: true,
  };

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

  Future<WorkoutPlanEntity?> preparePlanFor(
    DateTime date, {
    required ActiveProgramEntry? activeProgram,
    required List<WorkoutSessionEntity> history,
    required Future<WorkoutReadiness> Function() readiness,
    bool adaptive = true,
  }) async {
    final plan = await ensurePlanFor(date, activeProgram: activeProgram);
    if (plan == null || !adaptive) return plan;
    final isToday = AppDateUtils.isSameDay(date, DateTime.now());
    if (!isToday ||
        plan.isAdapted ||
        plan.sessionId != null ||
        plan.programId == null) {
      return plan;
    }
    final adapted = adaptPlan(
      plan,
      history: history,
      catalog: await _catalogMap(),
      readiness: await readiness(),
    );
    await savePlan(adapted);
    return adapted;
  }

  WorkoutPlanEntity adaptPlan(
    WorkoutPlanEntity plan, {
    required List<WorkoutSessionEntity> history,
    required Map<String, ExerciseCatalogEntry> catalog,
    required WorkoutReadiness readiness,
  }) {
    final reasons = <String>[];
    final exercises = <WorkoutEntryEntity>[];
    for (final entry in plan.exercises) {
      final exercise = catalog[entry.exerciseId];
      final suggestion = WorkoutProgression.suggest(
        planned: entry,
        history: WorkoutProgression.historyOf(history, entry.exerciseId),
        weightStepKg: exercise?.weightStepKg ?? _defaultWeightStepKg,
        isDeload: plan.isDeload,
      );
      final reason = suggestion.reason;
      if (reason != null && entry.section == WorkoutSectionKind.main) {
        reasons.add(reason);
      }
      var sets = suggestion.sets;
      if (readiness.isLow &&
          entry.section == WorkoutSectionKind.main &&
          sets > _minAdaptedSets) {
        sets--;
      }
      exercises.add(
        entry.copyWith(
          targetSets: sets,
          targetReps: suggestion.reps,
          targetWeightKg: suggestion.weightKg,
        ),
      );
    }

    final notes = <String>[
      if (readiness.isLow)
        'Readiness is low (${readiness.reasons.join(', ')}), so WAVE trimmed '
            'one set from each main lift.',
      if (readiness.isHigh)
        'Readiness is high (${readiness.reasons.join(', ')}) — a good day to '
            'push the top set.',
      ...reasons.take(_maxInsightReasons),
    ];
    return plan.copyWith(
      exercises: exercises,
      isAdapted: true,
      insight: notes.isEmpty
          ? plan.insight
          : '${plan.insight}\n\n${notes.join('\n')}',
    );
  }

  static List<ExerciseCatalogEntry> alternativesOf(
    WorkoutEntryEntity entry,
    List<ExerciseCatalogEntry> catalog,
  ) {
    ExerciseCatalogEntry? current;
    for (final exercise in catalog) {
      if (exercise.id == entry.exerciseId) current = exercise;
    }
    final scored = <(ExerciseCatalogEntry, double)>[];
    for (final exercise in catalog) {
      if (exercise.id == entry.exerciseId) continue;
      var score = 0.0;
      for (final share in entry.muscleShares.entries) {
        final other = exercise.muscleShares[share.key];
        if (other != null) score += share.value < other ? share.value : other;
      }
      if (current != null && exercise.group == current.group) {
        score += _sameGroupBonus;
      }
      if (score > 0 && exercise.isAdded) score += _savedBonus;
      if (score > 0) scored.add((exercise, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final item in scored.take(_maxAlternatives)) item.$1];
  }

  WorkoutEntryEntity swapEntry(
    WorkoutEntryEntity entry,
    ExerciseCatalogEntry replacement, {
    required List<WorkoutSessionEntity> history,
  }) {
    final swapped = WorkoutEntryEntity.fromCatalog(
      replacement,
      id: '${replacement.id}-${DateTime.now().microsecondsSinceEpoch}',
      section: entry.section,
      sets: entry.targetSets,
    );
    final suggestion = WorkoutProgression.suggest(
      planned: swapped,
      history: WorkoutProgression.historyOf(history, replacement.id),
      weightStepKg: replacement.weightStepKg,
    );
    return swapped.copyWith(
      targetReps: suggestion.reps,
      targetWeightKg: suggestion.weightKg,
      groupId: entry.groupId,
    );
  }

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
    if (!activeProgram.isActiveOn(date)) return null;
    final day = program.dayOn(
      activeProgram.programDateOf(date),
      activeProgram.weekdays,
    );
    if (day == null) return null;

    final week = activeProgram.weekAt(date);
    final phase = activeProgram.hasFixedLength
        ? ProgramPhase.of(week, activeProgram.totalWeeks)
        : null;
    final isDeload = phase?.isDeload ?? program.isDeloadWeek(week);
    final entries = <WorkoutEntryEntity>[];
    var mainIndex = 0;
    for (var index = 0; index < day.exercises.length; index++) {
      final planned = day.exercises[index];
      final exercise = catalog[planned.exerciseId];
      if (exercise == null) continue;
      final isMain = planned.section == WorkoutSectionKind.main;
      final baseSets = planned.sets ?? exercise.defaultSets;
      final setBoost =
          phase != null && isMain && mainIndex < ProgramPhase.peakLifts
          ? phase.setDelta
          : 0;
      if (isMain) mainIndex++;
      entries.add(
        WorkoutEntryEntity.fromCatalog(
          exercise,
          id: '${planned.exerciseId}-$index',
          section: planned.section,
          sets: isDeload
              ? WorkoutProgression.deloadSetsOf(baseSets)
              : baseSets + setBoost,
          reps: planned.reps,
          restSeconds: planned.restSeconds,
          repsInReserve: phase != null && isMain
              ? (planned.repsInReserve ?? exercise.defaultRepsInReserve) +
                    phase.reserveDelta
              : planned.repsInReserve,
          weightKg: planned.weightKg,
        ),
      );
    }
    if (entries.isEmpty) return null;
    final dayNumber = activeProgram.dayNumberAt(date);

    return WorkoutPlanEntity(
      id: '${program.id}-${AppDateUtils.dateKey(date)}',
      date: AppDateUtils.dateOnly(date),
      name: day.name,
      focus: day.focus,
      goal: day.goal,
      insight: phase != null
          ? phase.insightOf(
              programName: program.name,
              dayName: day.name,
              focus: day.focus,
              day: dayNumber,
              totalDays: activeProgram.totalDays,
            )
          : _insightOf(
              program: program,
              day: day,
              week: week,
              isDeload: isDeload,
            ),
      durationMinutes: day.durationMinutes,
      exercises: entries,
      programId: program.id,
      programLabel: phase != null
          ? '${program.name} · Day $dayNumber of ${activeProgram.totalDays} '
                '· ${phase.label}'
          : '${program.name} Program · Week $week'
                '${isDeload ? ' · Deload' : ''}',
      isDeload: isDeload,
    );
  }

  String _insightOf({
    required WorkoutProgramEntity program,
    required ProgramDayEntry day,
    required int week,
    required bool isDeload,
  }) => isDeload
      ? 'Deload week $week of ${program.weeks}: WAVE cut your volume to about '
            '60% so your body can absorb the last block. Move well and leave '
            'the gym fresh.'
      : 'WAVE scheduled ${day.name} from your ${program.name} program, week '
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

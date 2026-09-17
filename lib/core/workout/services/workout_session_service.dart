import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/weight_log_entity.dart';
import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/health/services/health_service.dart';
import 'package:floww/core/progress/services/flow_score_calculator.dart';
import 'package:floww/core/workout/models/workout_completion.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';

class WorkoutCompletionResult {
  const WorkoutCompletionResult({
    required this.session,
    required this.flowScoreBefore,
    required this.flowScoreAfter,
  });

  final WorkoutSessionEntity session;
  final int flowScoreBefore;
  final int flowScoreAfter;
}

class WorkoutSessionService extends WorkoutFirestore {
  WorkoutSessionService({HealthService? healthService})
    : _healthService = healthService ?? HealthService();

  static const String _loadFailure = 'Could not load your workout sessions.';
  static const String _saveFailure =
      'Could not save your workout. Please try again.';
  static const String _dateField = 'date';
  static const String _startedAtField = 'startedAt';
  static const int _historyLimit = 60;
  static const int _heartRateBuckets = 11;

  final HealthService _healthService;

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      collectionOf(uid, AppCollection.workoutSessions);

  CollectionReference<Map<String, dynamic>> _weightLogs(String uid) =>
      collectionOf(uid, AppCollection.weightLogs);

  CollectionReference<Map<String, dynamic>> _dailyFlow(String uid) =>
      collectionOf(uid, AppCollection.dailyFlow);

  Stream<List<WorkoutSessionEntity>> watchSessionsFor(DateTime date) {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _sessions(uid)
        .where(_dateField, isEqualTo: AppDateUtils.dateKey(date))
        .snapshots()
        .map(_sessionsOf);
  }

  Stream<List<WorkoutSessionEntity>> watchRecentSessions() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _sessions(uid)
        .orderBy(_startedAtField, descending: true)
        .limit(_historyLimit)
        .snapshots()
        .map(_sessionsOf);
  }

  Stream<WorkoutSessionEntity?> watchSession(String id) {
    final uid = userId;
    if (uid == null) return Stream.value(null);
    return _sessions(uid).doc(id).snapshots().map((document) {
      final data = document.data();
      return data == null ? null : WorkoutSessionEntity.fromJson(data);
    });
  }

  Future<List<WorkoutSessionEntity>> loadRecentSessions() async {
    final uid = userId;
    if (uid == null) return const [];
    return guard('loadRecentSessions', _loadFailure, () async {
      final snapshot = await _sessions(uid)
          .orderBy(_startedAtField, descending: true)
          .limit(_historyLimit)
          .get();
      return _sessionsOf(snapshot);
    });
  }

  Future<WorkoutSessionEntity?> loadSession(String id) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('loadSession', _loadFailure, () async {
      final document = await _sessions(uid).doc(id).get();
      final data = document.data();
      return data == null ? null : WorkoutSessionEntity.fromJson(data);
    });
  }

  Future<WorkoutSessionEntity?> loadInProgressSession(DateTime date) async {
    final uid = userId;
    if (uid == null) return null;
    return guard('loadInProgressSession', _loadFailure, () async {
      final snapshot = await _sessions(uid)
          .where(_dateField, isEqualTo: AppDateUtils.dateKey(date))
          .get();
      for (final session in _sessionsOf(snapshot)) {
        if (session.isInProgress) return session;
      }
      return null;
    });
  }

  Future<WorkoutSessionEntity> startSession(WorkoutPlanEntity plan) async {
    final uid = requireUserId;
    final existing = await loadInProgressSession(plan.date);
    if (existing != null) return existing;

    final now = DateTime.now();
    final document = _sessions(uid).doc();
    final session = WorkoutSessionEntity(
      id: document.id,
      workoutId: plan.id,
      name: plan.name,
      date: plan.date,
      status: WorkoutSessionStatus.inProgress,
      startedAt: now,
      completedAt: now,
      durationSeconds: 0,
      exercises: plan.exercises,
      focus: plan.focus,
      goal: plan.goal,
      insight: plan.insight,
      programId: plan.programId,
      programLabel: plan.programLabel,
    );

    await guard(
      'startSession',
      _saveFailure,
      () => document.set(session.toJson()),
    );
    return session;
  }

  Future<void> saveProgress(WorkoutSessionEntity session) async {
    final uid = requireUserId;
    final totals = WorkoutMetrics.totalsOf(session.exercises);
    await guard(
      'saveProgress',
      _saveFailure,
      () => _sessions(uid).doc(session.id).set({
        'exercises': [for (final entry in session.exercises) entry.toJson()],
        'durationSeconds': session.durationSeconds,
        'completedAt': AppDateUtils.isoKey(DateTime.now()),
        'volumeKg': totals.volumeKg,
        'totalSets': totals.totalSets,
        'totalReps': totals.totalReps,
        'exerciseCount': totals.exerciseCount,
      }, SetOptions(merge: true)),
    );
  }

  Future<WorkoutCompletionResult> completeSession(
    WorkoutSessionEntity session,
  ) async {
    final uid = requireUserId;
    final totals = WorkoutMetrics.totalsOf(session.exercises);
    final bodyWeightKg = await _bodyWeightKg(uid);
    final completedAt = DateTime.now();
    final history = await loadRecentSessions();
    final previous = [
      for (final entry in history)
        if (entry.id != session.id && entry.isCompleted) entry,
    ];

    final muscles = WorkoutMetrics.muscleActivationOf(session.exercises);
    final effect = WorkoutMetrics.trainingEffectOf(
      totals: totals,
      durationSeconds: session.durationSeconds,
    );
    final records = WorkoutMetrics.personalRecordsOf(
      exercises: session.exercises,
      previousBests: WorkoutMetrics.bestsOf(previous),
    );
    final heartRate = await _heartRateSamples(session.startedAt, completedAt);
    final flow = await _updateFlowScore(
      uid,
      date: session.date,
      totalSets: totals.totalSets,
      previousSessions: previous,
    );

    final payload = <String, dynamic>{
      'status': WorkoutSessionStatus.completed.name,
      'completedAt': AppDateUtils.isoKey(completedAt),
      'durationSeconds': session.durationSeconds,
      'exercises': [for (final entry in session.exercises) entry.toJson()],
      'volumeKg': totals.volumeKg,
      'totalSets': totals.totalSets,
      'totalReps': totals.totalReps,
      'exerciseCount': totals.exerciseCount,
      'caloriesKcal': WorkoutMetrics.caloriesOf(
        totals: totals,
        durationSeconds: session.durationSeconds,
        bodyWeightKg: bodyWeightKg,
      ),
      'trainingEffect': effect,
      'muscleActivation': [for (final muscle in muscles) muscle.toJson()],
      'personalRecords': [for (final record in records) record.toJson()],
      'flowPoints': flow.after - flow.before,
      'flowScoreBefore': flow.before,
      'flowScoreAfter': flow.after,
      if (heartRate.average != null) 'averageHeartRate': heartRate.average,
      if (heartRate.peak != null) 'peakHeartRate': heartRate.peak,
      'heartRateSamples': heartRate.samples,
    };

    await guard(
      'completeSession',
      _saveFailure,
      () => _sessions(uid).doc(session.id).set(payload, SetOptions(merge: true)),
    );

    final completed = await loadSession(session.id);
    return WorkoutCompletionResult(
      session: completed ?? session,
      flowScoreBefore: flow.before,
      flowScoreAfter: flow.after,
    );
  }

  Future<void> updateNotes(String id, String notes) async {
    final uid = requireUserId;
    await guard(
      'updateNotes',
      _saveFailure,
      () => _sessions(uid).doc(id).set({'notes': notes}, SetOptions(merge: true)),
    );
  }

  Future<void> saveRecoveryMood(String id, RecoveryMood mood) async {
    final uid = requireUserId;
    await guard(
      'saveRecoveryMood',
      _saveFailure,
      () => _sessions(
        uid,
      ).doc(id).set({'recoveryMood': mood.name}, SetOptions(merge: true)),
    );
  }

  Future<void> addExercise(String id, WorkoutEntryEntity entry) async {
    final uid = requireUserId;
    await guard(
      'addExercise',
      _saveFailure,
      () => _sessions(uid).doc(id).set({
        'exercises': FieldValue.arrayUnion([entry.toJson()]),
      }, SetOptions(merge: true)),
    );
  }

  List<WorkoutSessionEntity> _sessionsOf(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => parseAll(
    snapshot.docs.map((doc) => doc.data()),
    WorkoutSessionEntity.fromJson,
  )..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  Future<double> _bodyWeightKg(String uid) async {
    try {
      final logs = await _weightLogs(uid)
          .orderBy('loggedAt', descending: true)
          .limit(1)
          .get();
      if (logs.docs.isNotEmpty) {
        return WeightLog.fromJson(logs.docs.first.data()).weightKg;
      }
      final onboarding = await firestore
          .collection(AppCollection.onboardingDetails)
          .doc(uid)
          .get();
      final profile = onboarding.data()?['profile'];
      if (profile is Map<String, dynamic>) {
        final weight = (profile['weightKg'] as num?)?.toDouble();
        if (weight != null && weight > 0) return weight;
      }
    } catch (_) {
      return WorkoutMetrics.fallbackBodyWeightKg;
    }
    return WorkoutMetrics.fallbackBodyWeightKg;
  }

  Future<_HeartRateSummary> _heartRateSamples(
    DateTime from,
    DateTime to,
  ) async {
    final samples = await _healthService.fetchHeartRateSamples(from, to);
    if (samples.isEmpty) return const _HeartRateSummary.empty();

    var total = 0;
    var peak = samples.first;
    for (final sample in samples) {
      total += sample;
      if (sample > peak) peak = sample;
    }
    return _HeartRateSummary(
      average: (total / samples.length).round(),
      peak: peak,
      samples: _downsample(samples),
    );
  }

  static List<int> _downsample(List<int> samples) {
    if (samples.length <= _heartRateBuckets) return samples;
    final step = samples.length / _heartRateBuckets;
    return [
      for (var index = 0; index < _heartRateBuckets; index++)
        samples[(index * step).floor().clamp(0, samples.length - 1)],
    ];
  }

  Future<_FlowScoreChange> _updateFlowScore(
    String uid, {
    required DateTime date,
    required int totalSets,
    required List<WorkoutSessionEntity> previousSessions,
  }) async {
    const calculator = FlowScoreCalculator();
    final key = AppDateUtils.dateKey(date);

    try {
      final document = _dailyFlow(uid).doc(key);
      final stored = await document.get();
      final data = stored.data();
      final entry = data == null
          ? DailyFlowEntry.empty(date)
          : DailyFlowEntry.fromJson(data);

      var priorSets = 0;
      for (final session in previousSessions) {
        if (AppDateUtils.isSameDay(session.date, date)) {
          priorSets += session.totalSets;
        }
      }

      final before = calculator.withWorkoutSets(entry, priorSets);
      final after = calculator.withWorkoutSets(entry, priorSets + totalSets);
      await document.set(after.toJson());
      return _FlowScoreChange(before.score, after.score);
    } catch (_) {
      return const _FlowScoreChange(0, 0);
    }
  }
}

class _HeartRateSummary {
  const _HeartRateSummary({
    required this.average,
    required this.peak,
    required this.samples,
  });

  const _HeartRateSummary.empty()
    : average = null,
      peak = null,
      samples = const [];

  final int? average;
  final int? peak;
  final List<int> samples;
}

class _FlowScoreChange {
  const _FlowScoreChange(this.before, this.after);

  final int before;
  final int after;
}

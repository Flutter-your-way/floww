import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/progress_state_entity.dart';
import 'package:floww/config/entities/weight_log_entity.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';

class ProgressException implements Exception {
  ProgressException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProgressGoals {
  const ProgressGoals({this.startWeightKg, this.targetWeightKg});

  static const empty = ProgressGoals();

  factory ProgressGoals.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final goals = json['goalsActivity'] as Map<String, dynamic>?;
    return ProgressGoals(
      startWeightKg: (profile?['weightKg'] as num?)?.toDouble(),
      targetWeightKg: (goals?['targetWeightKg'] as num?)?.toDouble(),
    );
  }

  final double? startWeightKg;
  final double? targetWeightKg;
}

class ProgressRecords {
  const ProgressRecords({
    required this.weights,
    required this.sessions,
    required this.habitDays,
    required this.storedFlow,
    required this.nutrition,
    required this.state,
    required this.goals,
  });

  static const empty = ProgressRecords(
    weights: [],
    sessions: [],
    habitDays: [],
    storedFlow: [],
    nutrition: NutritionLogs.empty,
    state: ProgressState.empty,
    goals: ProgressGoals.empty,
  );

  final List<WeightLog> weights;
  final List<WorkoutSessionLog> sessions;
  final List<HabitDayLog> habitDays;
  final List<DailyFlowEntry> storedFlow;
  final NutritionLogs nutrition;
  final ProgressState state;
  final ProgressGoals goals;
}

class ProgressService {
  ProgressService({NutritionLogService? nutritionLogService}) {
    _nutritionLogService = nutritionLogService;
  }

  static const int historyDays = 180;
  static const int habitHistoryDays = 60;
  static const int nutritionHistoryDays = 60;
  static const int weightLogLimit = 200;

  static const String _loggedAtField = 'loggedAt';
  static const String _completedAtField = 'completedAt';
  static const String _dateField = 'date';

  NutritionLogService? _nutritionLogService;

  NutritionLogService get _nutritionLogs =>
      _nutritionLogService ??= NutritionLogService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  String get _requireUserId {
    final uid = userId;
    if (uid == null) throw ProgressException('Please sign in again.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppCollection.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _weightLogs(String uid) =>
      _userDoc(uid).collection(AppCollection.weightLogs);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _userDoc(uid).collection(AppCollection.workoutSessions);

  CollectionReference<Map<String, dynamic>> _habitLogs(String uid) =>
      _userDoc(uid).collection(AppCollection.habitLogs);

  CollectionReference<Map<String, dynamic>> _dailyFlow(String uid) =>
      _userDoc(uid).collection(AppCollection.dailyFlow);

  DocumentReference<Map<String, dynamic>> _stateDoc(String uid) => _userDoc(
    uid,
  ).collection(AppCollection.progress).doc(AppCollection.progressState);

  DocumentReference<Map<String, dynamic>> _onboardingDoc(String uid) =>
      _firestore.collection(AppCollection.onboardingDetails).doc(uid);

  Stream<ProgressRecords> watchRecords() {
    final uid = userId;
    if (uid == null) return Stream.value(ProgressRecords.empty);

    final now = DateTime.now();
    final historyStart = AppDateUtils.addDays(
      AppDateUtils.dateOnly(now),
      -historyDays,
    );
    final habitStart = AppDateUtils.addDays(
      AppDateUtils.dateOnly(now),
      -habitHistoryDays,
    );
    final nutritionStart = AppDateUtils.addDays(
      AppDateUtils.dateOnly(now),
      -nutritionHistoryDays,
    );
    final nutritionEnd = AppDateUtils.addDays(AppDateUtils.dateOnly(now), 1);

    return combineLatest([
      _weightStream(uid),
      _sessionStream(uid, historyStart),
      _habitStream(uid, habitStart),
      _flowStream(uid, historyStart),
      _nutritionLogs.watchLogs(nutritionStart, nutritionEnd).handleError((
        Object error,
      ) {
        debugPrint('Progress nutrition logs unavailable: $error');
      }),
      _stateStream(uid),
      _goalsStream(uid),
    ]).map(
      (values) => ProgressRecords(
        weights: values[0]! as List<WeightLog>,
        sessions: values[1]! as List<WorkoutSessionLog>,
        habitDays: values[2]! as List<HabitDayLog>,
        storedFlow: values[3]! as List<DailyFlowEntry>,
        nutrition: values[4]! as NutritionLogs,
        state: values[5]! as ProgressState,
        goals: values[6]! as ProgressGoals,
      ),
    );
  }

  Stream<List<WeightLog>> _weightStream(String uid) => _weightLogs(uid)
      .orderBy(_loggedAtField)
      .limitToLast(weightLogLimit)
      .snapshots()
      .map((snapshot) => _parse(snapshot, WeightLog.fromJson));

  Stream<List<WorkoutSessionLog>> _sessionStream(String uid, DateTime from) =>
      _sessions(uid)
          .where(
            _completedAtField,
            isGreaterThanOrEqualTo: AppDateUtils.isoKey(from),
          )
          .orderBy(_completedAtField)
          .snapshots()
          .map((snapshot) => _parse(snapshot, WorkoutSessionLog.fromJson));

  Stream<List<HabitDayLog>> _habitStream(String uid, DateTime from) =>
      _habitLogs(uid)
          .where(_dateField, isGreaterThanOrEqualTo: AppDateUtils.dateKey(from))
          .orderBy(_dateField)
          .snapshots()
          .map((snapshot) => _parse(snapshot, HabitDayLog.fromJson));

  Stream<List<DailyFlowEntry>> _flowStream(String uid, DateTime from) =>
      _dailyFlow(uid)
          .where(_dateField, isGreaterThanOrEqualTo: AppDateUtils.dateKey(from))
          .orderBy(_dateField)
          .snapshots()
          .map((snapshot) => _parse(snapshot, DailyFlowEntry.fromJson));

  Stream<ProgressState> _stateStream(String uid) =>
      _stateDoc(uid).snapshots().map((document) {
        final data = document.data();
        return data == null
            ? ProgressState.empty
            : ProgressState.fromJson(data);
      });

  Stream<ProgressGoals> _goalsStream(String uid) =>
      _onboardingDoc(uid).snapshots().map((document) {
        final data = document.data();
        return data == null
            ? ProgressGoals.empty
            : ProgressGoals.fromJson(data);
      });

  Future<void> addWeightLog(double weightKg, DateTime loggedAt) async {
    final uid = _requireUserId;
    final document = _weightLogs(uid).doc();
    final log = WeightLog(
      id: document.id,
      weightKg: weightKg,
      loggedAt: loggedAt,
    );
    await _write(
      'addWeightLog',
      'Could not save your weight. Please try again.',
      () => document.set(log.toJson()),
    );
  }

  Future<void> saveDailyFlow(List<DailyFlowEntry> entries) async {
    final uid = userId;
    if (uid == null || entries.isEmpty) return;

    final batch = _firestore.batch();
    for (final entry in entries) {
      batch.set(
        _dailyFlow(uid).doc(AppDateUtils.dateKey(entry.date)),
        entry.toJson(),
      );
    }

    try {
      await batch.commit();
    } catch (e, stackTrace) {
      debugPrint('saveDailyFlow failed: $e\n$stackTrace');
    }
  }

  Future<void> saveState(ProgressState state) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await _stateDoc(uid).set(state.toJson());
    } catch (e, stackTrace) {
      debugPrint('saveState failed: $e\n$stackTrace');
    }
  }

  Future<void> _write(
    String operation,
    String failureMessage,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on ProgressException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw ProgressException(failureMessage);
    }
  }

  static List<T> _parse<T>(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final items = <T>[];
    for (final document in snapshot.docs) {
      try {
        items.add(parse(document.data()));
      } catch (e) {
        debugPrint('Skipped unreadable progress document ${document.id}: $e');
      }
    }
    return items;
  }
}

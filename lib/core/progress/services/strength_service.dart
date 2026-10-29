import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/strength_benchmark_entity.dart';
import 'package:floww/config/entities/weight_log_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class StrengthRecords {
  const StrengthRecords({
    required this.sessions,
    required this.benchmarks,
    required this.bodyWeightKg,
  });

  static const empty = StrengthRecords(
    sessions: [],
    benchmarks: [],
    bodyWeightKg: WorkoutMetrics.fallbackBodyWeightKg,
  );

  final List<WorkoutSessionEntity> sessions;
  final List<StrengthBenchmark> benchmarks;
  final double bodyWeightKg;
}

class StrengthService {
  StrengthService({WorkoutSessionService? sessionService})
    : _sessionService = sessionService ?? WorkoutSessionService();

  static const int benchmarkLimit = 200;
  static const String _loggedAtField = 'loggedAt';

  final WorkoutSessionService _sessionService;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping strength: $e');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppCollection.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _benchmarks(String uid) =>
      _userDoc(uid).collection(AppCollection.strengthBenchmarks);

  Stream<StrengthRecords> watch() {
    final uid = userId;
    if (uid == null) return Stream.value(StrengthRecords.empty);
    return combineLatest([
      _orFallback<List<WorkoutSessionEntity>>(
        _sessionService.watchRecentSessions(),
        const <WorkoutSessionEntity>[],
        'sessions',
      ),
      _orFallback<List<StrengthBenchmark>>(
        _benchmarkStream(uid),
        const <StrengthBenchmark>[],
        'benchmarks',
      ),
      _orFallback<double>(
        _bodyWeightStream(uid),
        WorkoutMetrics.fallbackBodyWeightKg,
        'body weight',
      ),
    ]).map(
      (values) => StrengthRecords(
        sessions: values[0]! as List<WorkoutSessionEntity>,
        benchmarks: values[1]! as List<StrengthBenchmark>,
        bodyWeightKg: values[2]! as double,
      ),
    );
  }

  Future<void> addBenchmark({
    required String muscle,
    required String exercise,
    required double weightKg,
    required int reps,
  }) async {
    final uid = userId;
    if (uid == null) throw ProgressException('Please sign in again.');
    final document = _benchmarks(uid).doc();
    final benchmark = StrengthBenchmark(
      id: document.id,
      muscle: muscle,
      exercise: exercise,
      weightKg: weightKg,
      reps: reps,
      loggedAt: DateTime.now(),
    );
    try {
      await document.set(benchmark.toJson());
    } catch (e, stackTrace) {
      debugPrint('addBenchmark failed: $e\n$stackTrace');
      throw ProgressException(
        'Could not save your benchmark. Please try again.',
      );
    }
  }

  Stream<List<StrengthBenchmark>> _benchmarkStream(String uid) =>
      _benchmarks(uid)
          .orderBy(_loggedAtField)
          .limitToLast(benchmarkLimit)
          .snapshots()
          .map(
            (snapshot) => [
              for (final doc in snapshot.docs) ?_tryParse(doc.data()),
            ],
          );

  Stream<double> _bodyWeightStream(String uid) => _userDoc(uid)
      .collection(AppCollection.weightLogs)
      .orderBy(_loggedAtField)
      .limitToLast(1)
      .snapshots()
      .asyncMap((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final weight = WeightLog.fromJson(snapshot.docs.last.data()).weightKg;
          if (weight > 0) return weight;
        }
        return _onboardingWeightKg(uid);
      });

  Future<double> _onboardingWeightKg(String uid) async {
    try {
      final onboarding = await _firestore
          .collection(AppCollection.onboardingDetails)
          .doc(uid)
          .get();
      final profile = onboarding.data()?['profile'];
      if (profile is Map<String, dynamic>) {
        final weight = (profile['weightKg'] as num?)?.toDouble();
        if (weight != null && weight > 0) return weight;
      }
    } catch (e) {
      debugPrint('read onboarding weight failed: $e');
    }
    return WorkoutMetrics.fallbackBodyWeightKg;
  }

  static Stream<T> _orFallback<T>(Stream<T> source, T fallback, String label) =>
      source.transform(
        StreamTransformer<T, T>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            debugPrint('strength $label stream failed: $error');
            sink.add(fallback);
          },
        ),
      );

  static StrengthBenchmark? _tryParse(Map<String, dynamic> json) {
    try {
      return StrengthBenchmark.fromJson(json);
    } catch (e) {
      debugPrint('Skipped unreadable strength benchmark ${json['id']}: $e');
      return null;
    }
  }
}

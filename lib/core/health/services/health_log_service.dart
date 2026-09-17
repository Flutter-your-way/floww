import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/health_day_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/health/models/health_snapshot.dart';

class HealthLogService {
  HealthLogService();

  static const String _dateField = 'date';

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping health logs: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _logs(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.healthLogs);

  Stream<List<HealthDayLog>> watchDays(DateTime from) {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _logs(uid)
        .where(_dateField, isGreaterThanOrEqualTo: AppDateUtils.dateKey(from))
        .orderBy(_dateField)
        .snapshots()
        .map((snapshot) => _parseAll(snapshot.docs.map((doc) => doc.data())));
  }

  Future<void> saveSnapshot(HealthSnapshot snapshot, {DateTime? date}) async {
    final uid = userId;
    if (uid == null || !snapshot.hasData) return;

    final day = AppDateUtils.dateOnly(date ?? DateTime.now());
    final log = HealthDayLog(
      date: day,
      steps: snapshot.steps,
      activeCaloriesKcal: snapshot.activeCaloriesKcal,
      sleepMinutes: snapshot.sleepMinutes,
      workoutCount: snapshot.workoutCount,
      syncedAt: snapshot.syncedAt ?? DateTime.now(),
      restingHeartRate: snapshot.restingHeartRate,
      hrvMs: snapshot.hrvMs,
    );

    try {
      await _logs(uid).doc(AppDateUtils.dateKey(day)).set(log.toJson());
    } catch (e, stackTrace) {
      debugPrint('saveSnapshot failed: $e\n$stackTrace');
    }
  }

  List<HealthDayLog> _parseAll(Iterable<Map<String, dynamic>> documents) {
    final logs = <HealthDayLog>[];
    for (final json in documents) {
      try {
        logs.add(HealthDayLog.fromJson(json));
      } catch (e) {
        debugPrint('Skipped unreadable health log ${json['date']}: $e');
      }
    }
    return logs;
  }
}

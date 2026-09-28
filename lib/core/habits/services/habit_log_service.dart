import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';

class HabitLogService {
  HabitLogService();

  static const String _dateField = 'date';

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping habit logs: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _logs(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.habitLogs);

  Stream<List<HabitDayLog>> watchDays(DateTime from) {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _logs(uid)
        .where(_dateField, isGreaterThanOrEqualTo: AppDateUtils.dateKey(from))
        .orderBy(_dateField)
        .snapshots()
        .map((snapshot) => _parseAll(snapshot.docs.map((doc) => doc.data())));
  }

  Future<void> saveDay(
    DateTime date,
    List<Habit> habits, {
    Set<String>? changedIds,
  }) async {
    final uid = userId;
    if (uid == null) return;

    final day = AppDateUtils.dateOnly(date);
    final document = _logs(uid).doc(AppDateUtils.dateKey(day));
    final stored = changedIds == null
        ? const <String, HabitLogEntry>{}
        : await _storedEntries(document);

    double valueOf(Habit habit) {
      if (changedIds == null || changedIds.contains(habit.id)) {
        return habit.value;
      }
      return stored[habit.id]?.value ?? habit.value;
    }

    final log = HabitDayLog(
      date: day,
      entries: [
        for (final habit in habits)
          HabitLogEntry(
            id: habit.id,
            title: habit.title,
            value: valueOf(habit),
            target: habit.target,
            metric: habit.metric.name,
            goal: habit.isLimit ? HabitGoalMath.limit : HabitGoalMath.build,
            due: habit.isDue,
          ),
      ],
    );

    await document.set(log.toJson());
  }

  Future<Map<String, HabitLogEntry>> _storedEntries(
    DocumentReference<Map<String, dynamic>> document,
  ) async {
    try {
      final data = (await document.get()).data();
      if (data == null) return const {};
      return {
        for (final entry in HabitDayLog.fromJson(data).entries) entry.id: entry,
      };
    } catch (e) {
      debugPrint('Stored habit day unavailable, saving as shown: $e');
      return const {};
    }
  }

  List<HabitDayLog> _parseAll(Iterable<Map<String, dynamic>> documents) {
    final logs = <HabitDayLog>[];
    for (final json in documents) {
      try {
        logs.add(HabitDayLog.fromJson(json));
      } catch (e) {
        debugPrint('Skipped unreadable habit log ${json['date']}: $e');
      }
    }
    return logs;
  }
}

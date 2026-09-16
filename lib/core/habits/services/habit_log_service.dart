import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';

class HabitLogService {
  HabitLogService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping log: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _logs(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.habitLogs);

  Future<void> saveDay(DateTime date, List<Habit> habits) async {
    final uid = userId;
    if (uid == null) return;

    final day = AppDateUtils.dateOnly(date);
    final log = HabitDayLog(
      date: day,
      entries: [
        for (final habit in habits)
          HabitLogEntry(
            id: habit.id,
            title: habit.title,
            value: habit.value,
            target: habit.target,
          ),
      ],
    );

    try {
      await _logs(uid).doc(AppDateUtils.dateKey(day)).set(log.toJson());
    } catch (e, stackTrace) {
      debugPrint('saveDay failed: $e\n$stackTrace');
    }
  }
}

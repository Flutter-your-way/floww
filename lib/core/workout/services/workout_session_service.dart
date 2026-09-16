import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/workout_session_log_entity.dart';

class WorkoutSessionService {
  WorkoutSessionService();

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

  CollectionReference<Map<String, dynamic>> _sessions(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.workoutSessions);

  Future<void> logSession({
    required String workoutId,
    required String name,
    required DateTime completedAt,
    required int durationSeconds,
    required int exerciseCount,
    required int totalSets,
    required double volumeKg,
  }) async {
    final uid = userId;
    if (uid == null) return;

    final document = _sessions(uid).doc();
    final session = WorkoutSessionLog(
      id: document.id,
      workoutId: workoutId,
      name: name,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      exerciseCount: exerciseCount,
      totalSets: totalSets,
      volumeKg: volumeKg,
    );

    try {
      await document.set(session.toJson());
    } catch (e, stackTrace) {
      debugPrint('logSession failed: $e\n$stackTrace');
    }
  }
}

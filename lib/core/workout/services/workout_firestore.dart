import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';

class WorkoutException implements Exception {
  WorkoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class WorkoutFirestore {
  WorkoutFirestore();

  static const String signedOutMessage = 'Please sign in again.';

  FirebaseAuth get auth => FirebaseAuth.instance;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping workout data: $e');
      return null;
    }
  }

  String get requireUserId {
    final uid = userId;
    if (uid == null) throw WorkoutException(signedOutMessage);
    return uid;
  }

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      firestore.collection(AppCollection.users).doc(uid);

  CollectionReference<Map<String, dynamic>> collectionOf(
    String uid,
    String name,
  ) => userDoc(uid).collection(name);

  DocumentReference<Map<String, dynamic>> stateDoc(String uid) => collectionOf(
    uid,
    AppCollection.workoutState,
  ).doc(AppCollection.workoutStateDoc);

  Future<T> guard<T>(
    String operation,
    String failureMessage,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on WorkoutException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw WorkoutException(failureMessage);
    }
  }

  List<T> parseAll<T>(
    Iterable<Map<String, dynamic>> documents,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final items = <T>[];
    for (final json in documents) {
      try {
        items.add(parse(json));
      } catch (e) {
        debugPrint('Skipped unreadable workout document ${json['id']}: $e');
      }
    }
    return items;
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/water_log.dart';

class NutritionLogException implements Exception {
  NutritionLogException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NutritionLogs {
  const NutritionLogs({required this.foods, required this.waters});

  static const empty = NutritionLogs(foods: [], waters: []);

  final List<FoodLog> foods;
  final List<WaterLog> waters;
}

class NutritionLogService {
  static const String _loggedAtField = 'loggedAt';
  static const int _recentLimit = 30;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => _auth.currentUser?.uid;

  String get _requireUserId {
    final uid = userId;
    if (uid == null) throw NutritionLogException('Please sign in again.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _foodLogs(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.foodLogs);

  CollectionReference<Map<String, dynamic>> _waterLogs(String uid) =>
      _firestore
          .collection(AppCollection.users)
          .doc(uid)
          .collection(AppCollection.waterLogs);

  Query<Map<String, dynamic>> _between(
    CollectionReference<Map<String, dynamic>> collection,
    DateTime from,
    DateTime to,
  ) => collection
      .where(_loggedAtField, isGreaterThanOrEqualTo: AppDateUtils.isoKey(from))
      .where(_loggedAtField, isLessThan: AppDateUtils.isoKey(to))
      .orderBy(_loggedAtField);

  static List<FoodLog> _foodLogsOf(QuerySnapshot<Map<String, dynamic>> snapshot) =>
      parseDocuments(snapshot.docs.map((doc) => doc.data()), FoodLog.fromJson);

  static List<WaterLog> _waterLogsOf(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => parseDocuments(snapshot.docs.map((doc) => doc.data()), WaterLog.fromJson);

  String newFoodLogId() => _foodLogs(_requireUserId).doc().id;

  Stream<NutritionLogs> watchLogs(DateTime from, DateTime to) {
    final uid = userId;
    if (uid == null) return Stream.value(NutritionLogs.empty);
    return combineLogs(
      _between(_foodLogs(uid), from, to).snapshots().map(_foodLogsOf),
      _between(_waterLogs(uid), from, to).snapshots().map(_waterLogsOf),
    );
  }

  Stream<List<FoodLog>> watchRecentFoodLogs() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _foodLogs(uid)
        .orderBy(_loggedAtField, descending: true)
        .limit(_recentLimit)
        .snapshots()
        .map(_foodLogsOf);
  }

  Future<List<FoodLog>> fetchFoodLogs(DateTime from, DateTime to) async {
    final uid = userId;
    if (uid == null) return const [];
    try {
      return _foodLogsOf(await _between(_foodLogs(uid), from, to).get());
    } catch (e, stackTrace) {
      debugPrint('fetchFoodLogs failed: $e\n$stackTrace');
      throw NutritionLogException('Could not load your food logs.');
    }
  }

  Future<void> addFoodLog(FoodLog log) => _write(
    'addFoodLog',
    'Could not save this meal. Please try again.',
    () => _foodLogs(_requireUserId).doc(log.id).set(log.toJson()),
  );

  Future<void> deleteFoodLog(String id) => _write(
    'deleteFoodLog',
    'Could not remove this food. Please try again.',
    () => _foodLogs(_requireUserId).doc(id).delete(),
  );

  Future<void> addWaterLog(double amountMl, DateTime loggedAt) => _write(
    'addWaterLog',
    'Could not log your water. Please try again.',
    () {
      final doc = _waterLogs(_requireUserId).doc();
      final log = WaterLog(id: doc.id, amountMl: amountMl, loggedAt: loggedAt);
      return doc.set(log.toJson());
    },
  );

  Future<void> deleteWaterLog(String id) => _write(
    'deleteWaterLog',
    'Could not remove this entry. Please try again.',
    () => _waterLogs(_requireUserId).doc(id).delete(),
  );

  Future<void> _write(
    String operation,
    String failureMessage,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on NutritionLogException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw NutritionLogException(failureMessage);
    }
  }

  @visibleForTesting
  static List<T> parseDocuments<T>(
    Iterable<Map<String, dynamic>> documents,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final items = <T>[];
    for (final json in documents) {
      try {
        items.add(parse(json));
      } catch (e) {
        debugPrint('Skipped unreadable nutrition log ${json['id']}: $e');
      }
    }
    return items;
  }

  @visibleForTesting
  static Stream<NutritionLogs> combineLogs(
    Stream<List<FoodLog>> foods,
    Stream<List<WaterLog>> waters,
  ) {
    late final StreamController<NutritionLogs> controller;
    StreamSubscription<List<FoodLog>>? foodSubscription;
    StreamSubscription<List<WaterLog>>? waterSubscription;
    List<FoodLog>? latestFoods;
    var latestWaters = const <WaterLog>[];

    void emit() {
      final foodLogs = latestFoods;
      if (foodLogs == null) return;
      controller.add(NutritionLogs(foods: foodLogs, waters: latestWaters));
    }

    controller = StreamController<NutritionLogs>(
      onListen: () {
        foodSubscription = foods.listen((logs) {
          latestFoods = logs;
          emit();
        }, onError: controller.addError);
        waterSubscription = waters.listen(
          (logs) {
            latestWaters = logs;
            emit();
          },
          onError: (Object error) {
            debugPrint('Water logs unavailable, showing food only: $error');
            latestWaters = const [];
            emit();
          },
        );
      },
      onCancel: () async {
        await foodSubscription?.cancel();
        await waterSubscription?.cancel();
      },
    );
    return controller.stream;
  }
}

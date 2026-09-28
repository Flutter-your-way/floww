import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/core/nutrition/models/custom_food.dart';

class CustomFoodException implements Exception {
  CustomFoodException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CustomFoodService {
  static const String _createdAtField = 'createdAt';
  static const int limit = 200;
  static const String _estimateIdPrefix = 'estimate-';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping custom foods: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _foods(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.customFoods);

  Stream<List<CustomFood>> watchFoods() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);

    return _foods(uid)
        .orderBy(_createdAtField, descending: true)
        .limit(limit)
        .snapshots()
        .map(_foodsOf);
  }

  Future<List<CustomFood>> loadFoods() async {
    final uid = userId;
    if (uid == null) return const [];

    try {
      final snapshot = await _foods(
        uid,
      ).orderBy(_createdAtField, descending: true).limit(limit).get();
      return _foodsOf(snapshot);
    } catch (e, stackTrace) {
      debugPrint('load custom foods failed: $e\n$stackTrace');
      return const [];
    }
  }

  Future<CustomFood> create(CustomFoodDraft draft) => _save(draft, null);

  Future<CustomFood> saveEstimate(CustomFoodDraft draft) =>
      _save(draft, _estimateIdOf(draft.name));

  static String? _estimateIdOf(String name) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? null : '$_estimateIdPrefix$slug';
  }

  Future<CustomFood> _save(CustomFoodDraft draft, String? id) async {
    final uid = userId;
    if (uid == null) throw CustomFoodException('Please sign in again.');
    if (!draft.isValid) {
      throw CustomFoodException('Add a name and the calories per serving.');
    }

    final food = CustomFood(
      id: id ?? _foods(uid).doc().id,
      name: draft.name.trim(),
      serving: draft.serving.trim(),
      weightG: draft.weightG,
      calories: draft.calories,
      proteinG: draft.proteinG,
      carbsG: draft.carbsG,
      fatG: draft.fatG,
      fiberG: draft.fiberG,
      sugarG: draft.sugarG,
      sodiumMg: draft.sodiumMg,
      waterMl: draft.waterMl,
      createdAt: DateTime.now(),
    );

    try {
      await _foods(uid).doc(food.id).set(food.toJson());
      return food;
    } catch (e, stackTrace) {
      debugPrint('create custom food failed: $e\n$stackTrace');
      throw CustomFoodException('Could not save that food. Please try again.');
    }
  }

  Future<void> delete(String id) async {
    final uid = userId;
    if (uid == null) throw CustomFoodException('Please sign in again.');

    try {
      await _foods(uid).doc(id).delete();
    } catch (e, stackTrace) {
      debugPrint('delete custom food failed: $e\n$stackTrace');
      throw CustomFoodException('Could not delete that food.');
    }
  }

  static List<CustomFood> _foodsOf(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final foods = <CustomFood>[];
    for (final doc in snapshot.docs) {
      try {
        foods.add(CustomFood.fromJson(doc.data()));
      } catch (e) {
        debugPrint('Skipped unreadable custom food ${doc.id}: $e');
      }
    }
    return foods;
  }
}

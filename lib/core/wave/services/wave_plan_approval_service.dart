import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/core/wave/models/wave_pending_plan.dart';

class WavePlanApprovalService {
  WavePlanApprovalService();

  static const String _messageIdField = 'messageId';

  String? get userId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      debugPrint('wave approval auth unavailable: $e');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) => FirebaseFirestore
      .instance
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.waveState)
      .doc(AppCollection.wavePendingPlanDoc);

  Stream<WavePendingPlan?> watch() {
    final uid = userId;
    if (uid == null) return Stream.value(null);
    return _doc(
      uid,
    ).snapshots().map((snapshot) => WavePendingPlan.fromJson(snapshot.data()));
  }

  Future<void> propose(WavePendingPlan plan) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await _doc(uid).set(plan.toJson());
    } catch (e) {
      debugPrint('save pending plan failed: $e');
    }
  }

  Future<void> clear(String messageId) async {
    final uid = userId;
    if (uid == null) return;
    final ref = _doc(uid);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (snapshot.data()?[_messageIdField] != messageId) return;
        transaction.delete(ref);
      });
    } catch (e) {
      debugPrint('clear pending plan failed: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';

class WaveTranscriptService {
  WaveTranscriptService();

  static const String _createdAtField = 'createdAt';
  static const int historyLimit = 100;

  String? get userId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      debugPrint('wave auth unavailable: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _messages(String uid) =>
      FirebaseFirestore.instance
          .collection(AppCollection.users)
          .doc(uid)
          .collection(AppCollection.waveMessages);

  String newId() {
    final uid = userId;
    if (uid == null) return DateTime.now().microsecondsSinceEpoch.toString();
    return _messages(uid).doc().id;
  }

  Stream<List<WaveTranscriptEntry>> watch() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _messages(uid)
        .orderBy(_createdAtField, descending: true)
        .limit(historyLimit)
        .snapshots()
        .map(_entriesOf);
  }

  Future<void> save(WaveTranscriptEntry entry) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await _messages(uid).doc(entry.id).set(entry.toJson());
    } catch (e, stackTrace) {
      debugPrint('save wave message failed: $e\n$stackTrace');
    }
  }

  Future<void> clear() async {
    final uid = userId;
    if (uid == null) return;
    try {
      final snapshot = await _messages(uid).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e, stackTrace) {
      debugPrint('clear wave messages failed: $e\n$stackTrace');
    }
  }

  static List<WaveTranscriptEntry> _entriesOf(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final entries = <WaveTranscriptEntry>[];
    for (final doc in snapshot.docs) {
      try {
        entries.add(WaveTranscriptEntry.fromJson(doc.data()));
      } catch (e) {
        debugPrint('Skipped unreadable wave message ${doc.id}: $e');
      }
    }
    return entries.reversed.toList();
  }
}

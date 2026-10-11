import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/wave/models/wave_memory_note.dart';
import 'package:floww/core/wave/models/wave_summary_item.dart';

class WaveMemoryService {
  WaveMemoryService();

  static const String _updatedAtField = 'updatedAt';
  static const String _summaryField = 'summary';
  static const String _itemsField = 'items';
  static const String _summarizedThroughField = 'summarizedThrough';
  static const int noteLimit = 100;

  String? get userId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      debugPrint('wave memory auth unavailable: $e');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      FirebaseFirestore.instance.collection(AppCollection.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _notes(String uid) =>
      _user(uid).collection(AppCollection.waveMemories);

  DocumentReference<Map<String, dynamic>> _summary(String uid) => _user(
    uid,
  ).collection(AppCollection.waveState).doc(AppCollection.waveSummaryDoc);

  Stream<List<WaveMemoryNote>> watchNotes() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _notes(uid)
        .orderBy(_updatedAtField, descending: true)
        .limit(noteLimit)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              if (WaveMemoryNote.fromJson(doc.id, doc.data()) case final note
                  when note.text.isNotEmpty)
                note,
          ],
        );
  }

  Stream<List<WaveSummaryItem>> watchSummary() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);
    return _summary(
      uid,
    ).snapshots().map((snapshot) => WaveSummaryItem.listOf(snapshot.data()));
  }

  Future<void> deleteSummaryItem(WaveSummaryItem item) async {
    final uid = userId;
    if (uid == null) return;
    final ref = _summary(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final kept = WaveSummaryItem.listOf(snapshot.data()).where(
        (current) =>
            current.section != item.section || current.text != item.text,
      );
      transaction.set(ref, {
        _itemsField: [for (final current in kept) current.toJson()],
      }, SetOptions(merge: true));
    });
  }

  Future<void> deleteNote(String id) async {
    final uid = userId;
    if (uid == null) return;
    await _notes(uid).doc(id).delete();
  }

  Future<void> clearSummary() async {
    final uid = userId;
    if (uid == null) return;
    await _summary(uid).set(_clearedSummary(), SetOptions(merge: true));
  }

  Future<void> forgetEverything() async {
    final uid = userId;
    if (uid == null) return;
    final notes = await _notes(uid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in notes.docs) {
      batch.delete(doc.reference);
    }
    batch.set(_summary(uid), _clearedSummary(), SetOptions(merge: true));
    await batch.commit();
  }

  static Map<String, dynamic> _clearedSummary() => {
    _summaryField: '',
    _itemsField: const <Map<String, dynamic>>[],
    _summarizedThroughField: AppDateUtils.isoKey(DateTime.now()),
  };
}

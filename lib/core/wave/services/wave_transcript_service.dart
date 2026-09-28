import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/wave/models/wave_chat_day.dart';
import 'package:floww/core/wave/models/wave_transcript_entry.dart';

class WaveTranscriptService {
  WaveTranscriptService();

  static const String _createdAtField = 'createdAt';
  static const String _dayField = 'day';
  static const int dayLimit = 365;
  static const int backfillLimit = 1000;
  static const int previewLimit = 90;

  bool _didBackfill = false;

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

  CollectionReference<Map<String, dynamic>> _days(String uid) =>
      FirebaseFirestore.instance
          .collection(AppCollection.users)
          .doc(uid)
          .collection(AppCollection.waveDays);

  String newId() {
    final uid = userId;
    if (uid == null) return DateTime.now().microsecondsSinceEpoch.toString();
    return _messages(uid).doc().id;
  }

  Stream<List<WaveTranscriptEntry>> watchDay(DateTime day) {
    final uid = userId;
    if (uid == null) return Stream.value(const []);

    final start = AppDateUtils.dateOnly(day);
    final end = AppDateUtils.addDays(start, 1);

    return _messages(uid)
        .where(
          _createdAtField,
          isGreaterThanOrEqualTo: AppDateUtils.isoKey(start),
          isLessThan: AppDateUtils.isoKey(end),
        )
        .orderBy(_createdAtField)
        .snapshots()
        .map(_entriesOf);
  }

  Stream<List<WaveChatDay>> watchDays() {
    final uid = userId;
    if (uid == null) return Stream.value(const []);

    return _days(uid)
        .orderBy(_dayField, descending: true)
        .limit(dayLimit)
        .snapshots()
        .map(_daysOf);
  }

  Future<void> save(WaveTranscriptEntry entry) async {
    final uid = userId;
    if (uid == null) return;
    try {
      await _messages(uid).doc(entry.id).set(entry.toJson());
      await _touchDay(uid, entry);
    } catch (e, stackTrace) {
      debugPrint('save wave message failed: $e\n$stackTrace');
    }
  }

  Future<void> backfillDays() async {
    final uid = userId;
    if (uid == null || _didBackfill) return;
    _didBackfill = true;

    try {
      final existing = await _days(uid).limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final messages = await _messages(
        uid,
      ).orderBy(_createdAtField).limit(backfillLimit).get();
      if (messages.docs.isEmpty) return;

      final days = <String, WaveChatDay>{};
      for (final doc in messages.docs) {
        try {
          final entry = WaveTranscriptEntry.fromJson(doc.data());
          final day = AppDateUtils.dateOnly(entry.createdAt);
          days[AppDateUtils.dateKey(day)] = WaveChatDay(
            date: day,
            lastMessageAt: entry.createdAt,
            preview:
                _previewOf(entry) ??
                days[AppDateUtils.dateKey(day)]?.preview ??
                '',
          );
        } catch (e) {
          debugPrint('Skipped unreadable wave message ${doc.id}: $e');
        }
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final day in days.values) {
        batch.set(_days(uid).doc(day.key), day.toJson());
      }
      await batch.commit();
    } catch (e, stackTrace) {
      debugPrint('backfill wave days failed: $e\n$stackTrace');
    }
  }

  Future<void> _touchDay(String uid, WaveTranscriptEntry entry) async {
    final day = AppDateUtils.dateOnly(entry.createdAt);
    final preview = _previewOf(entry);

    await _days(uid).doc(AppDateUtils.dateKey(day)).set({
      _dayField: AppDateUtils.dateKey(day),
      'lastMessageAt': AppDateUtils.isoKey(entry.createdAt),
      'preview': ?preview,
    }, SetOptions(merge: true));
  }

  static String? _previewOf(WaveTranscriptEntry entry) {
    final text = entry.text ?? entry.title;
    if (text == null) return null;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length <= previewLimit
        ? trimmed
        : '${trimmed.substring(0, previewLimit)}…';
  }

  static List<WaveChatDay> _daysOf(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final days = <WaveChatDay>[];
    for (final doc in snapshot.docs) {
      try {
        days.add(WaveChatDay.fromJson(doc.data()));
      } catch (e) {
        debugPrint('Skipped unreadable wave day ${doc.id}: $e');
      }
    }
    return days;
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
    return entries;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/services/habit_catalog_data.dart';
import 'package:floww/core/habits/services/habit_log_service.dart';

class HabitException implements Exception {
  HabitException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HabitRecords {
  const HabitRecords({required this.habits, required this.days});

  static const empty = HabitRecords(habits: [], days: []);

  final List<HabitDefinition> habits;
  final List<HabitDayLog> days;
}

class HabitService {
  HabitService({HabitLogService? logService})
    : _logService = logService ?? HabitLogService();

  static const int historyDays = 370;
  static const String signedOutMessage = 'Please sign in again.';

  static const String _sortOrderField = 'sortOrder';

  final HabitLogService _logService;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String? get userId {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      debugPrint('Firebase unavailable, skipping habits: $e');
      return null;
    }
  }

  String get _requireUserId {
    final uid = userId;
    if (uid == null) throw HabitException(signedOutMessage);
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _habits(String uid) => _firestore
      .collection(AppCollection.users)
      .doc(uid)
      .collection(AppCollection.habits);

  List<HabitSuggestion> get suggestions => HabitCatalogData.suggestions;

  List<HabitSuggestionGroup> get suggestionGroups => HabitCatalogData.groups;

  Stream<HabitRecords> watchRecords() {
    final uid = userId;
    if (uid == null) return Stream.value(HabitRecords.empty);

    final from = AppDateUtils.addDays(
      AppDateUtils.dateOnly(DateTime.now()),
      -historyDays,
    );

    return combineLatest([_habitStream(uid), _logService.watchDays(from)]).map(
      (values) => HabitRecords(
        habits: values[0]! as List<HabitDefinition>,
        days: values[1]! as List<HabitDayLog>,
      ),
    );
  }

  Future<String> createHabit(
    HabitDraft draft, {
    String? id,
    HabitIconKind icon = HabitIconKind.clipboard,
    String? about,
  }) => _guard(
    'createHabit',
    'Could not add this habit. Please try again.',
    () async {
      final uid = _requireUserId;
      final collection = _habits(uid);
      final document = id == null ? collection.doc() : collection.doc(id);
      final habit = HabitDefinition(
        id: document.id,
        title: draft.title,
        target: draft.target,
        metric: draft.metric,
        icon: icon,
        createdAt: AppDateUtils.dateOnly(DateTime.now()),
        sortOrder: DateTime.now().millisecondsSinceEpoch,
        description: draft.description,
        about: about,
      );
      await document.set(habit.toJson());
      return document.id;
    },
  );

  Future<void> addSuggestion(HabitSuggestion suggestion) => createHabit(
    HabitDraft(
      title: suggestion.title,
      target: suggestion.target,
      metric: suggestion.metric,
      description: suggestion.description,
    ),
    id: suggestion.id,
    icon: suggestion.icon,
    about: suggestion.about,
  );

  Future<void> updateHabit(String id, HabitDraft draft) => _guard(
    'updateHabit',
    'Could not save your changes. Please try again.',
    () => _habits(_requireUserId).doc(id).update({
      'title': draft.title,
      'target': draft.target,
      'metric': draft.metric.name,
      'description': draft.description,
    }),
  );

  Future<void> deleteHabit(String id) => _guard(
    'deleteHabit',
    'Could not remove this habit. Please try again.',
    () => _habits(_requireUserId).doc(id).delete(),
  );

  Future<void> saveDay(DateTime date, List<Habit> habits) => _guard(
    'saveDay',
    'Could not save your habits. Please try again.',
    () => _logService.saveDay(date, habits),
  );

  Stream<List<HabitDefinition>> _habitStream(String uid) => _habits(uid)
      .orderBy(_sortOrderField)
      .snapshots()
      .map((snapshot) => _parseAll(snapshot.docs.map((doc) => doc.data())));

  List<HabitDefinition> _parseAll(Iterable<Map<String, dynamic>> documents) {
    final habits = <HabitDefinition>[];
    for (final json in documents) {
      try {
        habits.add(HabitDefinition.fromJson(json));
      } catch (e) {
        debugPrint('Skipped unreadable habit ${json['id']}: $e');
      }
    }
    return habits;
  }

  Future<T> _guard<T>(
    String operation,
    String failureMessage,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on HabitException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('$operation failed: $e\n$stackTrace');
      throw HabitException(failureMessage);
    }
  }
}

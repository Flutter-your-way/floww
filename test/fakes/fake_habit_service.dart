import 'dart:async';

import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/models/habit_reminder_setting.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/services/habit_catalog_data.dart';
import 'package:floww/core/habits/services/habit_service.dart';

class FakeHabitService implements HabitService {
  FakeHabitService({
    List<HabitDefinition> habits = const [],
    List<HabitDayLog> days = const [],
    this.userId = 'user-1',
    this.accountCreatedAt,
    this.writeError,
  }) : _habits = [...habits],
       _days = {for (final day in days) AppDateUtils.dateKey(day.date): day};

  @override
  final String? userId;

  @override
  final DateTime? accountCreatedAt;

  final HabitException? writeError;

  final List<HabitDayLog> savedDays = [];

  final List<HabitDefinition> _habits;
  final Map<String, HabitDayLog> _days;
  final StreamController<HabitRecords> _controller =
      StreamController<HabitRecords>.broadcast();

  int _nextId = 0;

  HabitRecords get _records =>
      HabitRecords(habits: [..._habits], days: [..._days.values]);

  @override
  List<HabitSuggestion> get suggestions => HabitCatalogData.suggestions;

  @override
  List<HabitSuggestionGroup> get suggestionGroups => HabitCatalogData.groups;

  @override
  Stream<String?> watchUserId() => Stream.value(userId);

  @override
  Stream<HabitRecords> watchRecords({
    int days = HabitService.historyDays,
  }) async* {
    yield _records;
    yield* _controller.stream;
  }

  @override
  Future<String> createHabit(
    HabitDraft draft, {
    String? id,
    HabitIconKind icon = HabitIconKind.clipboard,
    String? about,
  }) async {
    _throwOnError();
    final habitId = id ?? 'habit-${++_nextId}';
    _habits.add(
      HabitDefinition(
        id: habitId,
        title: draft.title,
        target: draft.target,
        metric: draft.metric,
        icon: icon,
        createdAt: AppDateUtils.dateOnly(DateTime.now()),
        sortOrder: _habits.length,
        description: draft.description,
        about: about,
      ),
    );
    _emit();
    return habitId;
  }

  @override
  Future<void> addSuggestion(
    HabitSuggestion suggestion, {
    HabitReminderSetting reminder = const HabitReminderSetting.auto(),
  }) => createHabit(
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

  @override
  Future<void> updateHabit(String id, HabitDraft draft) async {
    _throwOnError();
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index < 0) return;
    final habit = _habits[index];
    _habits[index] = HabitDefinition(
      id: habit.id,
      title: draft.title,
      target: draft.target,
      metric: draft.metric,
      icon: habit.icon,
      createdAt: habit.createdAt,
      sortOrder: habit.sortOrder,
      description: draft.description,
      about: habit.about,
    );
    _emit();
  }

  @override
  Future<void> restoreHabit(HabitDefinition definition) async {
    _throwOnError();
    _habits.removeWhere((habit) => habit.id == definition.id);
    _habits.add(definition);
    _emit();
  }

  @override
  Future<void> addMissing(List<HabitSuggestion> suggestions) async {
    for (final suggestion in suggestions) {
      if (_habits.any((habit) => habit.id == suggestion.id)) continue;
      await addSuggestion(suggestion);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    _throwOnError();
    _habits.removeWhere((habit) => habit.id == id);
    _emit();
  }

  @override
  Future<void> saveDay(
    DateTime date,
    List<Habit> habits, {
    Set<String>? changedIds,
  }) async {
    _throwOnError();
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
            metric: habit.metric.name,
          ),
      ],
    );
    savedDays.add(log);
    _days[AppDateUtils.dateKey(day)] = log;
    _emit();
  }

  void dispose() => _controller.close();

  void _emit() => _controller.add(_records);

  void _throwOnError() {
    final error = writeError;
    if (error != null) throw error;
  }
}

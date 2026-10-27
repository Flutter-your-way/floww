import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_definition.dart';
import 'package:floww/core/habits/models/habit_reminder.dart';
import 'package:floww/core/habits/services/habit_reminder_service.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';
import 'package:floww/core/settings/services/settings_service.dart';

class HabitReminderProvider {
  HabitReminderProvider({
    HabitService? habitService,
    SettingsService? settingsService,
    HabitReminderService? reminderService,
  }) : _habitService = habitService ?? HabitService(),
       _settingsService = settingsService ?? SettingsService(),
       _reminderService = reminderService ?? HabitReminderService();

  static const String notificationId = 'habit_reminder';
  static const int _horizonDays = 7;
  static const int _maxScheduled = 48;
  static const String _buildBody = 'Time to work on this habit today.';
  static const String _limitBody =
      'A quick check-in to stay within your limit.';

  final HabitService _habitService;
  final SettingsService _settingsService;
  final HabitReminderService _reminderService;

  StreamSubscription<String?>? _userWatch;
  StreamSubscription<List<Object?>>? _dataWatch;
  Future<void> _queue = Future.value();
  String? _lastSignature;

  void start() {
    _userWatch ??= _habitService.watchUserId().listen(
      _onUser,
      onError: (Object error) =>
          debugPrint('habit reminder user watch failed: $error'),
    );
  }

  void dispose() {
    _userWatch?.cancel();
    _dataWatch?.cancel();
  }

  void _onUser(String? uid) {
    _dataWatch?.cancel();
    _dataWatch = null;
    if (uid == null) {
      _apply(const []);
      return;
    }
    _dataWatch =
        combineLatest([
          _habitService.watchRecords(days: 0),
          _settingsService.watchNotifications(),
        ]).listen(
          (values) => _apply(
            _isEnabled(values[1]! as NotificationSettings)
                ? plan(values[0]! as HabitRecords, DateTime.now())
                : const [],
          ),
          onError: (Object error) =>
              debugPrint('habit reminder watch failed: $error'),
        );
  }

  bool _isEnabled(NotificationSettings settings) {
    if (!settings.master.isEnabled) return false;
    for (final section in settings.sections) {
      for (final item in section.items) {
        if (item.id == notificationId) return item.isEnabled;
      }
    }
    return true;
  }

  void _apply(List<HabitReminder> reminders) {
    final signature = [
      for (final reminder in reminders)
        '${reminder.habitId}|${reminder.title}|${reminder.body}|'
            '${reminder.at.millisecondsSinceEpoch}',
    ].join(',');
    if (signature == _lastSignature) return;
    _lastSignature = signature;
    _queue = _queue.then((_) => _reminderService.replaceAll(reminders));
  }

  @visibleForTesting
  static List<HabitReminder> plan(HabitRecords records, DateTime now) {
    final today = AppDateUtils.dateOnly(now);
    final todayLog = records.days
        .where((day) => AppDateUtils.isSameDay(day.date, today))
        .firstOrNull;
    final reminders = <HabitReminder>[];
    for (final habit in records.habits) {
      final minutes = habit.reminderMinutes;
      if (minutes == null || habit.isArchived) continue;
      for (var offset = 0; offset < _horizonDays; offset++) {
        final day = AppDateUtils.addDays(today, offset);
        if (!habit.schedule.isScheduledOn(day)) continue;
        if (offset == 0 && _isDone(habit, todayLog)) continue;
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          minutes ~/ Duration.minutesPerHour,
          minutes % Duration.minutesPerHour,
        );
        if (!at.isAfter(now)) continue;
        reminders.add(
          HabitReminder(
            habitId: habit.id,
            title: habit.title,
            body: _bodyOf(habit),
            at: at,
          ),
        );
      }
    }
    reminders.sort((a, b) => a.at.compareTo(b.at));
    return reminders.take(_maxScheduled).toList();
  }

  static bool _isDone(HabitDefinition habit, HabitDayLog? todayLog) {
    if (habit.goalType == HabitGoalType.limit) return false;
    return todayLog?.entryOf(habit.id)?.isCompleted ?? false;
  }

  static String _bodyOf(HabitDefinition habit) {
    final description = habit.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return habit.goalType == HabitGoalType.limit ? _limitBody : _buildBody;
  }
}

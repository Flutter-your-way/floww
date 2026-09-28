import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/health/models/health_snapshot.dart';
import 'package:floww/core/health/providers/health_provider.dart';

class HabitSourceValues {
  const HabitSourceValues({this.steps = 0, this.sleepMinutes = 0});

  static const double _minutesPerHour = 60;
  static const Set<HabitSource> deviceSources = {
    HabitSource.steps,
    HabitSource.sleep,
  };

  factory HabitSourceValues.of({
    required DateTime day,
    required HealthSnapshot health,
  }) {
    final syncedAt = health.syncedAt;
    final hasHealth = syncedAt != null && AppDateUtils.isSameDay(syncedAt, day);

    return HabitSourceValues(
      steps: hasHealth ? health.steps.toDouble() : 0,
      sleepMinutes: hasHealth ? health.sleepMinutes.toDouble() : 0,
    );
  }

  final double steps;
  final double sleepMinutes;

  double valueFor(HabitSource source, HabitMetric metric) => switch (source) {
    HabitSource.steps => steps,
    HabitSource.sleep =>
      metric == HabitMetric.minutes
          ? sleepMinutes
          : sleepMinutes / _minutesPerHour,
    _ => 0,
  };
}

class HabitSourceSync {
  HabitSourceSync(this._health, {HabitService? habitService})
    : _habitService = habitService ?? HabitService();

  static const double _tolerance = 0.01;

  final HealthProvider _health;
  final HabitService _habitService;

  DayRolloverTimer? _dayRollover;
  StreamSubscription<HabitRecords>? _subscription;
  HabitRecords? _records;
  bool _isSaving = false;
  bool _hasPendingSync = false;

  void start() {
    _health.addListener(_onHealthChanged);
    _dayRollover = DayRolloverTimer(_onNewDay);
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _habitService.watchRecords().listen(
      (records) {
        _records = records;
        unawaited(_sync());
      },
      onError: (Object error) => debugPrint('Habit source sync failed: $error'),
    );
  }

  void _onHealthChanged() => unawaited(_sync());

  void _onNewDay() {
    _records = null;
    _subscribe();
    unawaited(_health.refresh());
  }

  Future<void> _sync() async {
    final records = _records;
    if (records == null) return;
    if (_isSaving) {
      _hasPendingSync = true;
      return;
    }

    final today = AppDateUtils.dateOnly(DateTime.now());
    final values = HabitSourceValues.of(day: today, health: _health.snapshot);

    final changedIds = <String>{};
    final updated = <Habit>[];
    for (final habit in HabitSnapshot.of(records).habitsFor(today)) {
      final isDeviceSource =
          HabitSourceValues.deviceSources.contains(habit.source) &&
          !habit.isLimit;
      final synced = isDeviceSource
          ? values.valueFor(habit.source, habit.metric)
          : 0.0;
      if (synced > habit.value + _tolerance) {
        changedIds.add(habit.id);
        updated.add(habit.copyWith(value: synced));
      } else {
        updated.add(habit);
      }
    }
    if (changedIds.isEmpty) return;

    _isSaving = true;
    try {
      await _habitService.saveDay(today, updated, changedIds: changedIds);
    } on HabitException catch (e) {
      debugPrint('Habit source save failed: ${e.message}');
    } finally {
      _isSaving = false;
    }

    if (_hasPendingSync) {
      _hasPendingSync = false;
      await _sync();
    }
  }

  void dispose() {
    _health.removeListener(_onHealthChanged);
    _dayRollover?.cancel();
    _subscription?.cancel();
  }
}

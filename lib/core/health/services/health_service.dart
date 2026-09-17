import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/health_snapshot.dart';

class HealthServiceException implements Exception {
  HealthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HealthService {
  HealthService({Health? client}) : _health = client ?? Health();

  final Health _health;

  bool _configured = false;

  static HealthDataType get hrvType => Platform.isIOS
      ? HealthDataType.HEART_RATE_VARIABILITY_SDNN
      : HealthDataType.HEART_RATE_VARIABILITY_RMSSD;

  static List<HealthDataType> get readTypes => <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    hrvType,
  ];

  static List<HealthDataType> get _dailyTypes => <HealthDataType>[
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  List<HealthDataAccess> get _readAccess =>
      List<HealthDataAccess>.filled(readTypes.length, HealthDataAccess.READ);

  Future<void> configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> isSupported() async {
    if (Platform.isIOS) return true;
    if (!Platform.isAndroid) return false;
    try {
      return await _health.isHealthConnectAvailable();
    } catch (e, stackTrace) {
      debugPrint('isSupported failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    await configure();
    try {
      final granted = await _health.hasPermissions(
        readTypes,
        permissions: _readAccess,
      );
      return granted ?? false;
    } catch (e, stackTrace) {
      debugPrint('hasPermissions failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    await configure();
    try {
      return await _health.requestAuthorization(
        readTypes,
        permissions: _readAccess,
      );
    } catch (e, stackTrace) {
      debugPrint('requestPermissions failed: $e\n$stackTrace');
      throw HealthServiceException(
        'Could not open Apple Health. Please try again.',
      );
    }
  }

  Future<HealthSnapshot> fetchTodaySnapshot() async {
    await configure();
    try {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final sleepWindowStart = dayStart.subtract(const Duration(hours: 12));

      final steps = await _health.getTotalStepsInInterval(dayStart, now) ?? 0;

      final dailyPoints = await _health.getHealthDataFromTypes(
        types: _dailyTypes,
        startTime: dayStart,
        endTime: now,
      );

      final sleepPoints = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.SLEEP_ASLEEP],
        startTime: sleepWindowStart,
        endTime: now,
      );

      final hrvPoints = await _health.getHealthDataFromTypes(
        types: [hrvType],
        startTime: sleepWindowStart,
        endTime: now,
      );

      var activeCalories = 0.0;
      var sleepMinutes = 0.0;
      var workoutCount = 0;
      int? restingHeartRate;

      for (final point in dailyPoints) {
        final value = point.value;
        if (point.type == HealthDataType.WORKOUT) {
          workoutCount++;
        } else if (value is NumericHealthValue) {
          if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeCalories += value.numericValue;
          } else if (point.type == HealthDataType.RESTING_HEART_RATE) {
            restingHeartRate = value.numericValue.round();
          }
        }
      }

      for (final point in sleepPoints) {
        final value = point.value;
        if (value is NumericHealthValue) {
          sleepMinutes += value.numericValue;
        }
      }

      var hrvTotal = 0.0;
      var hrvCount = 0;
      for (final point in hrvPoints) {
        final value = point.value;
        if (value is NumericHealthValue) {
          hrvTotal += value.numericValue;
          hrvCount++;
        }
      }

      return HealthSnapshot(
        steps: steps,
        activeCaloriesKcal: activeCalories.round(),
        restingHeartRate: restingHeartRate,
        sleepMinutes: sleepMinutes.round(),
        workoutCount: workoutCount,
        syncedAt: now,
        hrvMs: hrvCount == 0 ? null : hrvTotal / hrvCount,
      );
    } catch (e, stackTrace) {
      debugPrint('fetchTodaySnapshot failed: $e\n$stackTrace');
      throw HealthServiceException('Could not read your Apple Health data.');
    }
  }

  Future<List<int>> fetchHeartRateSamples(DateTime from, DateTime to) async {
    if (!to.isAfter(from)) return const [];
    try {
      await configure();
      if (!await hasPermissions()) return const [];
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.HEART_RATE],
        startTime: from,
        endTime: to,
      );
      final samples = <int>[];
      for (final point in points) {
        final value = point.value;
        if (value is NumericHealthValue) {
          samples.add(value.numericValue.round());
        }
      }
      return samples;
    } catch (e, stackTrace) {
      debugPrint('fetchHeartRateSamples failed: $e\n$stackTrace');
      return const [];
    }
  }
}

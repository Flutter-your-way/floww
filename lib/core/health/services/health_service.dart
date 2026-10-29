import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import 'package:floww/config/constants/app_integrations.dart';

import '../models/health_metric_reading.dart';
import '../models/health_snapshot.dart';
import '../models/health_vitals.dart';
import 'health_kit_channel.dart';

class HealthServiceException implements Exception {
  HealthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HealthService {
  HealthService({Health? client, HealthKitChannel? healthKit})
    : _health = client ?? Health(),
      _healthKit = healthKit ?? const HealthKitChannel();

  static const int permissionsVersion = 2;
  static const Duration _vitalsWindow = Duration(days: 30);
  static const Duration _bodyWindow = Duration(days: 365);
  static const Duration _readTimeout = Duration(seconds: 8);

  final Health _health;
  final HealthKitChannel _healthKit;

  bool _configured = false;

  static bool get usesAppleHealth => Platform.isIOS;

  static String get sourceId => Platform.isIOS
      ? AppIntegrations.appleHealth
      : AppIntegrations.healthConnect;

  static String get sourceName => Platform.isIOS
      ? AppIntegrations.appleHealthName
      : AppIntegrations.healthConnectName;

  static HealthDataType get hrvType => Platform.isIOS
      ? HealthDataType.HEART_RATE_VARIABILITY_SDNN
      : HealthDataType.HEART_RATE_VARIABILITY_RMSSD;

  static HealthDataType get skinTemperatureType => Platform.isIOS
      ? HealthDataType.SLEEP_WRIST_TEMPERATURE
      : HealthDataType.SKIN_TEMPERATURE;

  static List<HealthDataType> get readTypes => <HealthDataType>[
    ..._coreTypes,
    ..._vitalTypes,
    ..._bodyTypes,
  ];

  static List<HealthDataType> get _vitalTypes => <HealthDataType>[
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    skinTemperatureType,
  ];

  static List<HealthDataType> get _bodyTypes => <HealthDataType>[
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.LEAN_BODY_MASS,
    if (Platform.isIOS) HealthDataType.BODY_MASS_INDEX,
  ];

  static List<HealthDataType> get _coreTypes => <HealthDataType>[
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

  List<HealthDataAccess> _readAccessOf(List<HealthDataType> types) =>
      List<HealthDataAccess>.filled(types.length, HealthDataAccess.READ);

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

  Future<bool> needsHealthConnectInstall() async {
    if (!Platform.isAndroid) return false;
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status ==
          HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired;
    } catch (e, stackTrace) {
      debugPrint('needsHealthConnectInstall failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> installHealthConnect() async {
    try {
      await _health.installHealthConnect();
    } catch (e, stackTrace) {
      debugPrint('installHealthConnect failed: $e\n$stackTrace');
    }
  }

  Future<bool> hasPermissions() async {
    await configure();
    try {
      final granted = await _health.hasPermissions(
        _coreTypes,
        permissions: _readAccessOf(_coreTypes),
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
      final granted = await _health.requestAuthorization(
        readTypes,
        permissions: _readAccessOf(readTypes),
      );
      if (granted) await _healthKit.requestAuthorization();
      return granted;
    } catch (e, stackTrace) {
      debugPrint('requestPermissions failed: $e\n$stackTrace');
      throw HealthServiceException(
        'Could not open $sourceName. Please try again.',
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
      throw HealthServiceException('Could not read your $sourceName data.');
    }
  }

  Future<HealthVitals> fetchVitals() async {
    await configure();
    final now = DateTime.now();
    final vitalsStart = now.subtract(_vitalsWindow);
    final bodyStart = now.subtract(_bodyWindow);

    final results = await Future.wait([
      _readingOf(hrvType, vitalsStart, now),
      _readingOf(HealthDataType.RESTING_HEART_RATE, vitalsStart, now),
      _kitReadingOf(HealthKitMetric.vo2Max, bodyStart, now),
      _kitReadingOf(HealthKitMetric.heartRateRecovery, vitalsStart, now),
      _readingOf(
        HealthDataType.BLOOD_OXYGEN,
        vitalsStart,
        now,
        transform: _asPercent,
      ),
      _readingOf(skinTemperatureType, vitalsStart, now),
      _readingOf(HealthDataType.RESPIRATORY_RATE, vitalsStart, now),
      _readingOf(HealthDataType.WEIGHT, bodyStart, now),
      _readingOf(
        HealthDataType.BODY_FAT_PERCENTAGE,
        bodyStart,
        now,
        transform: _asPercent,
      ),
      _readingOf(HealthDataType.LEAN_BODY_MASS, bodyStart, now),
      if (Platform.isIOS)
        _readingOf(HealthDataType.BODY_MASS_INDEX, bodyStart, now)
      else
        Future<HealthMetricReading?>.value(),
    ]);

    return HealthVitals(
      hrv: results[0],
      restingHeartRate: results[1],
      vo2Max: results[2],
      heartRateRecovery: results[3],
      oxygenSaturation: results[4],
      skinTemperature: results[5],
      respiratoryRate: results[6],
      weight: results[7],
      bodyFat: results[8],
      leanMass: results[9],
      bodyMassIndex: results[10],
    );
  }

  static double _asPercent(double value) => value <= 1 ? value * 100 : value;

  Future<HealthMetricReading?> _readingOf(
    HealthDataType type,
    DateTime from,
    DateTime to, {
    double Function(double value)? transform,
  }) async {
    try {
      final points = await _health
          .getHealthDataFromTypes(types: [type], startTime: from, endTime: to)
          .timeout(_readTimeout);
      final samples = <HealthSample>[];
      for (final point in points) {
        final value = point.value;
        if (value is! NumericHealthValue) continue;
        final number = value.numericValue.toDouble();
        samples.add(
          HealthSample(
            value: transform == null ? number : transform(number),
            at: point.dateTo,
          ),
        );
      }
      return HealthMetricReading.latestOf(samples);
    } catch (e, stackTrace) {
      debugPrint('read ${type.name} failed: $e\n$stackTrace');
      return null;
    }
  }

  Future<HealthMetricReading?> _kitReadingOf(
    HealthKitMetric metric,
    DateTime from,
    DateTime to,
  ) async => HealthMetricReading.latestOf(
    await _healthKit
        .samples(metric, from, to)
        .timeout(_readTimeout, onTimeout: () => const []),
  );

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

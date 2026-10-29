import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:floww/core/health/models/health_metric_reading.dart';

enum HealthKitMetric { vo2Max, heartRateRecovery }

class HealthKitChannel {
  const HealthKitChannel();

  static const MethodChannel _channel = MethodChannel('floww/health_kit');
  static const String _authorizeMethod = 'requestAuthorization';
  static const String _samplesMethod = 'samples';

  Future<bool> requestAuthorization() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>(_authorizeMethod) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e, stackTrace) {
      debugPrint('health kit authorization failed: $e\n$stackTrace');
      return false;
    }
  }

  Future<List<HealthSample>> samples(
    HealthKitMetric metric,
    DateTime from,
    DateTime to,
  ) async {
    if (!Platform.isIOS) return const [];
    try {
      final raw = await _channel.invokeListMethod<Map>(_samplesMethod, {
        'type': metric.name,
        'from': from.millisecondsSinceEpoch,
        'to': to.millisecondsSinceEpoch,
      });
      return [
        for (final entry in raw ?? const <Map>[])
          if (entry['value'] is num && entry['date'] is num)
            HealthSample(
              value: (entry['value'] as num).toDouble(),
              at: DateTime.fromMillisecondsSinceEpoch(
                (entry['date'] as num).toInt(),
              ),
            ),
      ];
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (e, stackTrace) {
      debugPrint('health kit samples failed: $e\n$stackTrace');
      return const [];
    }
  }
}

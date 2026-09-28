import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutAlertService {
  WorkoutAlertService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _restNotificationId = 4101;
  static const String _channelId = 'workout_rest';
  static const String _channelName = 'Rest timer';
  static const String _channelDescription =
      'Tells you when your rest between sets is over';
  static const String _androidIcon = '@mipmap/ic_launcher';
  static const String _title = 'Rest is over';

  static bool _initialized = false;
  static bool _permissionRequested = false;

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> keepAwake(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (error) {
      debugPrint('keepAwake failed: $error');
    }
  }

  Future<void> scheduleRestEnd(DateTime endsAt, String nextLabel) async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _restNotificationId);
      if (!endsAt.isAfter(DateTime.now())) return;
      await _plugin.zonedSchedule(
        id: _restNotificationId,
        title: _title,
        body: nextLabel,
        scheduledDate: tz.TZDateTime.from(endsAt.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('scheduleRestEnd failed: $error');
    }
  }

  Future<void> cancelRestEnd() async {
    try {
      if (!_initialized) return;
      await _plugin.cancel(id: _restNotificationId);
    } catch (error) {
      debugPrint('cancelRestEnd failed: $error');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_androidIcon),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _initialized = true;
    }
    if (_permissionRequested) return;
    _permissionRequested = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }
}

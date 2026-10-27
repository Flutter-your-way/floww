import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotifications {
  LocalNotifications._();

  static const String _androidIcon = '@mipmap/ic_launcher';

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _permissionRequested = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await plugin.initialize(
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

  static bool get isInitialized => _initialized;

  static Future<void> requestPermissionOnce() async {
    await ensureInitialized();
    if (_permissionRequested) return;
    _permissionRequested = true;
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }
}

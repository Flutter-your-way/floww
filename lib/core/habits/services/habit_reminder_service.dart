import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:floww/config/utils/notifications/local_notifications.dart';
import 'package:floww/core/habits/models/habit_reminder.dart';

class HabitReminderService {
  HabitReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? LocalNotifications.plugin;

  static const String _payload = 'habit_reminder';
  static const int _baseId = 20000;
  static const String _channelId = 'habit_reminder';
  static const String _channelName = 'Habit reminders';
  static const String _channelDescription =
      'Reminds you to complete your habits at the time you chose';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> replaceAll(List<HabitReminder> reminders) async {
    try {
      if (reminders.isEmpty && !LocalNotifications.isInitialized) return;
      if (reminders.isEmpty) {
        await _cancelScheduled();
        return;
      }
      await LocalNotifications.requestPermissionOnce();
      await _cancelScheduled();
      for (var index = 0; index < reminders.length; index++) {
        final reminder = reminders[index];
        await _plugin.zonedSchedule(
          id: _baseId + index,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime.from(reminder.at.toUtc(), tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: _payload,
        );
      }
    } catch (error) {
      debugPrint('habit reminders sync failed: $error');
    }
  }

  Future<void> _cancelScheduled() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.payload == _payload) await _plugin.cancel(id: request.id);
    }
  }
}

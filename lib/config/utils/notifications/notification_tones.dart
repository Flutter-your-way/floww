import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:floww/config/constants/app_sounds.dart';
import 'package:floww/config/utils/notifications/local_notifications.dart';

enum NotificationTone { system, chime, ripple, pulse, bell }

extension NotificationToneInfo on NotificationTone {
  String get label => switch (this) {
    NotificationTone.system => 'Default',
    NotificationTone.chime => 'Chime',
    NotificationTone.ripple => 'Ripple',
    NotificationTone.pulse => 'Pulse',
    NotificationTone.bell => 'Bell',
  };

  String? get soundName => switch (this) {
    NotificationTone.system => null,
    NotificationTone.chime => AppSounds.chime,
    NotificationTone.ripple => AppSounds.ripple,
    NotificationTone.pulse => AppSounds.pulse,
    NotificationTone.bell => AppSounds.bell,
  };
}

class NotificationTones {
  NotificationTones._();

  static const String _prefsKey = 'notification_tone';
  static const String _soundsFolder = 'Sounds';
  static const int _previewId = 4999;
  static const String _previewChannelId = 'tone_preview';
  static const String _previewChannelName = 'Tone preview';
  static const String _previewTitle = 'Reminder tone';
  static const String _previewBody = 'This is how your FLOWW reminders sound.';

  static final ValueNotifier<NotificationTone> selected = ValueNotifier(
    NotificationTone.system,
  );

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefsKey);
      selected.value = NotificationTone.values.firstWhere(
        (tone) => tone.name == name,
        orElse: () => NotificationTone.system,
      );
      await _installIosSounds();
    } catch (error) {
      debugPrint('NotificationTones load failed: $error');
    }
  }

  static Future<void> select(NotificationTone tone) async {
    selected.value = tone;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, tone.name);
      await preview(tone);
    } catch (error) {
      debugPrint('NotificationTones select failed: $error');
    }
  }

  static Future<void> preview(NotificationTone tone) async {
    await LocalNotifications.requestPermissionOnce();
    await LocalNotifications.plugin.show(
      id: _previewId,
      title: _previewTitle,
      body: _previewBody,
      notificationDetails: details(
        channelId: _previewChannelId,
        channelName: _previewChannelName,
        channelDescription: _previewBody,
        tone: tone,
      ),
    );
  }

  static NotificationDetails details({
    required String channelId,
    required String channelName,
    required String channelDescription,
    NotificationTone? tone,
    InterruptionLevel? interruptionLevel,
  }) {
    final active = tone ?? selected.value;
    final sound = active.soundName;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        sound == null ? channelId : '${channelId}_${active.name}',
        sound == null ? channelName : '$channelName · ${active.label}',
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: sound == null
            ? null
            : RawResourceAndroidNotificationSound(sound),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        sound: sound == null ? null : AppSounds.fileOf(sound),
        interruptionLevel: interruptionLevel,
      ),
    );
  }

  static Future<void> _installIosSounds() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final library = await getLibraryDirectory();
    final folder = Directory('${library.path}/$_soundsFolder');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    for (final tone in NotificationTone.values) {
      final sound = tone.soundName;
      if (sound == null) continue;
      final file = File('${folder.path}/${AppSounds.fileOf(sound)}');
      if (file.existsSync()) continue;
      final data = await rootBundle.load(AppSounds.assetOf(sound));
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }
  }
}

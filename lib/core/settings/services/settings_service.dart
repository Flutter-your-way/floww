import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_collection.dart';
import 'package:floww/config/constants/app_integrations.dart';
import 'package:floww/config/constants/app_images.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class SettingsService {
  SettingsService();

  static const String notificationsField = 'notifications';
  static const String connectedAppsField = 'connectedApps';
  static const String waveField = 'wave';
  static const String waveMemoryFlag = 'memory';
  static const String dietPlanStartedAtField = 'dietPlanStartedAt';
  static const String flowModeOverrideField = 'flowModeOverride';
  static const String _overrideDateField = 'date';
  static const String _overrideModeField = 'mode';

  static const _defaultConnectedApps = [
    ConnectedAppItem(
      id: AppIntegrations.appleHealth,
      name: AppIntegrations.appleHealthName,
      isConnected: false,
      kind: ConnectedAppKind.appleHealth,
      iconAsset: AppImages.appleHealthIcon,
    ),
    ConnectedAppItem(
      id: AppIntegrations.garmin,
      name: 'Garmin®',
      isConnected: false,
      kind: ConnectedAppKind.cloud,
      wordmark: 'GARMIN',
    ),
    ConnectedAppItem(
      id: AppIntegrations.whoop,
      name: 'WHOOP',
      isConnected: false,
      kind: ConnectedAppKind.cloud,
      iconAsset: AppImages.whoopIcon,
    ),
    ConnectedAppItem(
      id: AppIntegrations.oura,
      name: 'Oura',
      isConnected: false,
      kind: ConnectedAppKind.cloud,
      iconAsset: AppImages.ouraIcon,
    ),
    ConnectedAppItem(
      id: AppIntegrations.fitbit,
      name: 'Fitbit',
      isConnected: false,
      kind: ConnectedAppKind.cloud,
      iconAsset: AppImages.fitbitIcon,
    ),
    ConnectedAppItem(
      id: AppIntegrations.healthConnect,
      name: AppIntegrations.healthConnectName,
      isConnected: false,
      kind: ConnectedAppKind.healthConnect,
      iconAsset: AppImages.healthConnectIcon,
    ),
  ];

  static const _defaultNotifications = NotificationSettings(
    master: NotificationToggleItem(
      id: 'master',
      title: 'Notifications',
      subtitle: 'Workout, habit & sleep reminders',
      isEnabled: true,
    ),
    sections: [
      NotificationSection(
        title: 'Fitness',
        items: [
          NotificationToggleItem(
            id: 'workout_reminder',
            title: 'Workout Reminder',
            subtitle: 'Daily nudge at your preferred time',
            isEnabled: true,
          ),
          NotificationToggleItem(
            id: 'habit_reminder',
            title: 'Habit Reminder',
            subtitle: 'Reminder to complete daily habits',
            isEnabled: true,
          ),
          NotificationToggleItem(
            id: 'streak_alerts',
            title: 'Streak Alerts',
            subtitle: "Don't break your streak reminders",
            isEnabled: false,
          ),
        ],
      ),
      NotificationSection(
        title: 'Lifestyle',
        items: [
          NotificationToggleItem(
            id: 'water_reminder',
            title: 'Water Reminder',
            subtitle: 'Hydration nudges every 2 hours',
            isEnabled: true,
          ),
          NotificationToggleItem(
            id: 'sleep_reminder',
            title: 'Sleep Reminder',
            subtitle: 'Bedtime reminder based on your schedule',
            isEnabled: true,
          ),
        ],
      ),
      NotificationSection(
        title: 'Wave',
        items: [
          NotificationToggleItem(
            id: 'wave_insights',
            title: 'WAVE Insights',
            subtitle: 'Daily AI recommendation cards',
            isEnabled: true,
          ),
          NotificationToggleItem(
            id: 'weekly_summary',
            title: 'Weekly Summary',
            subtitle: 'Your progress report every Sunday',
            isEnabled: true,
          ),
        ],
      ),
    ],
  );

  static const _privacyLinks = [
    PrivacyLinkItem(
      id: 'privacy_policy',
      icon: Icons.shield_outlined,
      title: 'Privacy Policy',
      subtitle: 'How we use and protect your data',
    ),
    PrivacyLinkItem(
      id: 'data_sharing',
      icon: Icons.language_rounded,
      title: 'Data Sharing',
      subtitle: 'Manage what data we can analyze',
    ),
  ];

  static const _measurementOptions = [
    MeasurementOption(
      system: MeasurementSystem.metric,
      title: 'Metric',
      description: 'Kilometers, centimeters, kilograms, etc.',
    ),
    MeasurementOption(
      system: MeasurementSystem.imperial,
      title: 'Imperial',
      description: 'Miles, feet, pounds, Fahrenheit, etc.',
    ),
  ];

  String? get userId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      debugPrint('settings auth unavailable: $e');
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>>? _preferences() {
    final uid = userId;
    if (uid == null) return null;
    try {
      return FirebaseFirestore.instance
          .collection(AppCollection.users)
          .doc(uid)
          .collection(AppCollection.settings)
          .doc(AppCollection.settingsDoc);
    } catch (e) {
      debugPrint('settings store unavailable: $e');
      return null;
    }
  }

  List<ConnectedAppItem> defaultConnectedApps() => _defaultConnectedApps;

  NotificationSettings defaultNotifications() => _defaultNotifications;

  List<PrivacyLinkItem> privacyLinks() => _privacyLinks;

  List<MeasurementOption> measurementOptions() => _measurementOptions;

  Stream<List<ConnectedAppItem>> watchConnectedApps() =>
      _watchField(connectedAppsField).map(connectedAppsOf);

  Stream<NotificationSettings> watchNotifications() =>
      _watchField(notificationsField).map(notificationsOf);

  Future<bool> setConnected(String id, bool isConnected) =>
      _setFlag(connectedAppsField, id, isConnected);

  Future<bool> setNotificationEnabled(String id, bool isEnabled) =>
      _setFlag(notificationsField, id, isEnabled);

  Stream<bool> watchWaveMemoryEnabled() =>
      _watchField(waveField).map((flags) => flags[waveMemoryFlag] != false);

  Future<bool> setWaveMemoryEnabled(bool isEnabled) =>
      _setFlag(waveField, waveMemoryFlag, isEnabled);

  Future<bool> notificationEnabled(String id) async {
    final settings = await watchNotifications().first;
    if (settings.master.id == id) return settings.master.isEnabled;
    for (final section in settings.sections) {
      for (final item in section.items) {
        if (item.id == id) return item.isEnabled;
      }
    }
    return false;
  }

  bool isNotificationId(String id) =>
      _defaultNotifications.master.id == id ||
      _defaultNotifications.sections.any(
        (section) => section.items.any((item) => item.id == id),
      );

  String notificationTitleOf(String id) {
    if (_defaultNotifications.master.id == id) {
      return _defaultNotifications.master.title;
    }
    for (final section in _defaultNotifications.sections) {
      for (final item in section.items) {
        if (item.id == id) return item.title;
      }
    }
    return id;
  }

  Stream<AppThemeMode?> watchFlowModeOverride(DateTime date) {
    final document = _preferences();
    if (document == null) return Stream.value(null);
    return document
        .snapshots()
        .map((snapshot) => _overrideOf(snapshot.data(), date))
        .handleError(
          (Object error) => debugPrint('flow mode override failed: $error'),
        );
  }

  Future<AppThemeMode?> loadFlowModeOverride(DateTime date) async {
    final document = _preferences();
    if (document == null) return null;
    final snapshot = await document.get();
    return _overrideOf(snapshot.data(), date);
  }

  Future<void> setFlowModeOverride(DateTime date, AppThemeMode? mode) async {
    final document = _preferences();
    if (document == null) throw StateError('Please sign in again.');
    await document.set({
      flowModeOverrideField: mode == null
          ? FieldValue.delete()
          : {
              _overrideDateField: AppDateUtils.dateKey(date),
              _overrideModeField: mode.name,
            },
    }, SetOptions(merge: true));
  }

  static AppThemeMode? _overrideOf(Map<String, dynamic>? data, DateTime date) {
    final value = data?[flowModeOverrideField];
    if (value is! Map) return null;
    if (value[_overrideDateField] != AppDateUtils.dateKey(date)) return null;
    return AppThemeMode.values.asNameMap()[value[_overrideModeField]];
  }

  Future<DateTime?> dietPlanStartedAt() async {
    final document = _preferences();
    if (document == null) return null;
    try {
      final snapshot = await document.get();
      final value = snapshot.data()?[dietPlanStartedAtField];
      return value is String ? DateTime.tryParse(value) : null;
    } catch (e, stackTrace) {
      debugPrint('read diet plan start failed: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> setDietPlanStartedAt(DateTime date) async {
    final document = _preferences();
    if (document == null) return;
    try {
      await document.set({
        dietPlanStartedAtField: date.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('save diet plan start failed: $e\n$stackTrace');
    }
  }

  @visibleForTesting
  static List<ConnectedAppItem> connectedAppsOf(Map<String, dynamic> stored) =>
      [
        for (final app in _defaultConnectedApps)
          app.copyWith(isConnected: stored[app.id] as bool? ?? app.isConnected),
      ];

  @visibleForTesting
  static NotificationSettings notificationsOf(Map<String, dynamic> stored) {
    NotificationToggleItem toggle(NotificationToggleItem item) =>
        item.copyWith(isEnabled: stored[item.id] as bool? ?? item.isEnabled);

    return NotificationSettings(
      master: toggle(_defaultNotifications.master),
      sections: [
        for (final section in _defaultNotifications.sections)
          section.copyWith(
            items: [for (final item in section.items) toggle(item)],
          ),
      ],
    );
  }

  Stream<Map<String, dynamic>> _watchField(String field) {
    final document = _preferences();
    if (document == null) return Stream.value(const {});
    return document
        .snapshots()
        .map<Map<String, dynamic>>((snapshot) {
          final value = snapshot.data()?[field];
          return value is Map
              ? Map<String, dynamic>.from(value)
              : <String, dynamic>{};
        })
        .handleError(
          (Object error) => debugPrint('settings read failed: $error'),
        );
  }

  Future<bool> _setFlag(String field, String id, bool value) async {
    final document = _preferences();
    if (document == null) return false;
    try {
      await document.set({
        field: {id: value},
      }, SetOptions(merge: true));
      return true;
    } catch (e, stackTrace) {
      debugPrint('save settings failed: $e\n$stackTrace');
      return false;
    }
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_images.dart';
import 'package:floww/core/settings/models/settings_view_data.dart';

class SettingsService {
  const SettingsService();

  static const _connectedApps = [
    ConnectedAppItem(
      id: 'apple_health',
      name: 'Apple Health',
      isConnected: true,
      iconAsset: AppImages.appleHealthIcon,
    ),
    ConnectedAppItem(
      id: 'garmin',
      name: 'Garmin®',
      isConnected: false,
      wordmark: 'GARMIN',
    ),
    ConnectedAppItem(
      id: 'whoop',
      name: 'WHOOP',
      isConnected: false,
      iconAsset: AppImages.whoopIcon,
    ),
    ConnectedAppItem(
      id: 'oura',
      name: 'Oura',
      isConnected: false,
      iconAsset: AppImages.ouraIcon,
    ),
    ConnectedAppItem(
      id: 'fitbit',
      name: 'Fitbit',
      isConnected: false,
      iconAsset: AppImages.fitbitIcon,
    ),
    ConnectedAppItem(
      id: 'health_connect',
      name: 'Health Connect',
      isConnected: false,
      iconAsset: AppImages.healthConnectIcon,
    ),
  ];

  static const _notifications = NotificationSettings(
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

  List<ConnectedAppItem> connectedApps() => _connectedApps;

  NotificationSettings notifications() => _notifications;

  List<PrivacyLinkItem> privacyLinks() => _privacyLinks;

  List<MeasurementOption> measurementOptions() => _measurementOptions;

  MeasurementSystem measurementSystem() => MeasurementSystem.imperial;
}

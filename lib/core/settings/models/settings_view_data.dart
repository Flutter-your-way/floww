import 'package:flutter/material.dart';

import 'package:floww/config/entities/measurement_system.dart';

export 'package:floww/config/entities/measurement_system.dart';

class ConnectedAppItem {
  const ConnectedAppItem({
    required this.id,
    required this.name,
    required this.isConnected,
    this.iconAsset,
    this.wordmark,
  });

  final String id;
  final String name;
  final bool isConnected;
  final String? iconAsset;
  final String? wordmark;

  ConnectedAppItem copyWith({bool? isConnected}) => ConnectedAppItem(
    id: id,
    name: name,
    isConnected: isConnected ?? this.isConnected,
    iconAsset: iconAsset,
    wordmark: wordmark,
  );
}

class NotificationToggleItem {
  const NotificationToggleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool isEnabled;

  NotificationToggleItem copyWith({bool? isEnabled}) => NotificationToggleItem(
    id: id,
    title: title,
    subtitle: subtitle,
    isEnabled: isEnabled ?? this.isEnabled,
  );
}

class NotificationSection {
  const NotificationSection({required this.title, required this.items});

  final String title;
  final List<NotificationToggleItem> items;

  NotificationSection copyWith({List<NotificationToggleItem>? items}) =>
      NotificationSection(title: title, items: items ?? this.items);
}

class NotificationSettings {
  const NotificationSettings({required this.master, required this.sections});

  final NotificationToggleItem master;
  final List<NotificationSection> sections;

  NotificationSettings copyWith({
    NotificationToggleItem? master,
    List<NotificationSection>? sections,
  }) => NotificationSettings(
    master: master ?? this.master,
    sections: sections ?? this.sections,
  );
}

class PrivacyLinkItem {
  const PrivacyLinkItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
}

class MeasurementOption {
  const MeasurementOption({
    required this.system,
    required this.title,
    required this.description,
  });

  final MeasurementSystem system;
  final String title;
  final String description;
}

import 'package:flutter/material.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.initial,
    required this.name,
    required this.subtitle,
    required this.isPremium,
    this.avatarUrl,
  });

  final String initial;
  final String name;
  final String subtitle;
  final bool isPremium;
  final String? avatarUrl;
}

class ProfileMetricItem {
  const ProfileMetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
}

class ProfileMetricSection {
  const ProfileMetricSection({
    required this.title,
    required this.actionLabel,
    required this.items,
  });

  final String title;
  final String actionLabel;
  final List<ProfileMetricItem> items;
}

class ProfileSubscription {
  const ProfileSubscription({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.isActive,
    required this.hasPlan,
    this.badgeLabel,
  });

  final String title;
  final String message;
  final String actionLabel;
  final bool isActive;
  final bool hasPlan;
  final String? badgeLabel;
}

class ProfileSettingItem {
  const ProfileSettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

import 'package:flutter/widgets.dart';

import 'package:floww/core/achievements/models/achievement_category.dart';
import 'package:floww/core/achievements/models/badge_rarity.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.icon,
    required this.rarity,
    required this.title,
    required this.description,
    required this.xp,
    required this.category,
    required this.isUnlocked,
    this.badgeLabel,
  });

  final String id;
  final IconData icon;
  final BadgeRarity rarity;
  final String? badgeLabel;
  final String title;
  final String description;
  final int xp;
  final AchievementCategory category;
  final bool isUnlocked;

  String get xpLabel => isUnlocked ? '+$xp XP' : '$xp XP';

  Achievement unlocked(bool value) => Achievement(
    id: id,
    icon: icon,
    rarity: rarity,
    badgeLabel: badgeLabel,
    title: title,
    description: description,
    xp: xp,
    category: category,
    isUnlocked: value,
  );
}

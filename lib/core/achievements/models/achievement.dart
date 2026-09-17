import 'package:floww/core/achievements/models/achievement_category.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.xp,
    required this.category,
    required this.isUnlocked,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final int xp;
  final AchievementCategory category;
  final bool isUnlocked;

  String get xpLabel => isUnlocked ? '+$xp XP' : '$xp XP';

  Achievement unlocked(bool value) => Achievement(
    id: id,
    emoji: emoji,
    title: title,
    description: description,
    xp: xp,
    category: category,
    isUnlocked: value,
  );
}

import 'package:floww/core/achievements/models/badge_rarity.dart';

enum StreakBadgeTier {
  spark(3, BadgeRarity.bronze),
  week(7, BadgeRarity.silver),
  fortnight(14, BadgeRarity.gold),
  month(30, BadgeRarity.ember),
  century(100, BadgeRarity.prism);

  const StreakBadgeTier(this.days, this.rarity);

  final int days;
  final BadgeRarity rarity;

  String get daysLabel => '$days';
}

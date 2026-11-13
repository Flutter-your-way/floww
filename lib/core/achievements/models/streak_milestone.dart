import 'package:floww/core/achievements/models/streak_badge_tier.dart';

class StreakMilestone {
  const StreakMilestone({
    required this.tier,
    required this.title,
    required this.description,
    this.isReached = false,
  });

  final StreakBadgeTier tier;
  final String title;
  final String description;
  final bool isReached;

  StreakMilestone reached(int bestDays) => StreakMilestone(
    tier: tier,
    title: title,
    description: description,
    isReached: bestDays >= tier.days,
  );
}

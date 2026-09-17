import 'package:floww/core/achievements/models/streak_day.dart';
import 'package:floww/core/achievements/models/streak_day_status.dart';
import 'package:floww/core/achievements/models/streak_milestone.dart';

class StreakSummary {
  const StreakSummary({
    required this.currentDays,
    required this.bestDays,
    required this.monthCompletedDays,
    required this.monthTotalDays,
    required this.days,
    required this.milestones,
  });

  final int currentDays;
  final int bestDays;
  final int monthCompletedDays;
  final int monthTotalDays;
  final List<StreakDay> days;
  final List<StreakMilestone> milestones;

  String get currentLabel => '${currentDays}d';

  String get bestLabel => '${bestDays}d';

  String get monthLabel => '$monthCompletedDays/$monthTotalDays';

  int countOf(StreakDayStatus status) =>
      days.where((day) => day.status == status).length;
}

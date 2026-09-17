import 'package:floww/core/achievements/models/streak_day_status.dart';

class StreakDay {
  const StreakDay({required this.label, required this.status});

  final String label;
  final StreakDayStatus status;
}

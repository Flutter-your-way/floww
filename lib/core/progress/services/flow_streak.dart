import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';

class FlowStreak {
  FlowStreak._();

  static bool _isActive(DailyFlowEntry? entry) => entry?.hasActivity ?? false;

  static bool _bridges(DailyFlowEntry? entry) =>
      entry != null && (entry.hasActivity || entry.isRestDay);

  static int currentOf(Map<String, DailyFlowEntry> flow, DateTime today) {
    var cursor = AppDateUtils.dateOnly(today);
    if (!_isActive(flow[AppDateUtils.dateKey(cursor)])) {
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    var streak = 0;
    while (_bridges(flow[AppDateUtils.dateKey(cursor)])) {
      if (_isActive(flow[AppDateUtils.dateKey(cursor)])) streak++;
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  static int longestOf(Map<String, DailyFlowEntry> flow) {
    final days =
        flow.values
            .where(_bridges)
            .map((entry) => AppDateUtils.dateOnly(entry.date))
            .toList()
          ..sort();
    var longest = 0;
    var running = 0;
    DateTime? previous;
    for (final day in days) {
      if (previous == null || AppDateUtils.daysBetween(previous, day) != 1) {
        running = 0;
      }
      if (_isActive(flow[AppDateUtils.dateKey(day)])) running++;
      if (running > longest) longest = running;
      previous = day;
    }
    return longest;
  }
}

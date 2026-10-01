import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';

class FlowScoreHandover {
  const FlowScoreHandover();

  static const int handoverDays = 3;
  static const int _maxScore = 100;

  int displayOf({
    required DailyFlowEntry entry,
    required int? baseline,
    required DateTime? memberSince,
    required DateTime today,
  }) {
    final floor = _floorOf(baseline, memberSince, today);
    if (floor == null) return entry.score;
    if (!entry.hasActivity) return floor;
    final lifted = floor + (_maxScore - floor) * entry.score / _maxScore;
    return lifted.round().clamp(0, _maxScore);
  }

  int? _floorOf(int? baseline, DateTime? memberSince, DateTime today) {
    if (baseline == null || baseline <= 0 || memberSince == null) return null;
    final dayIndex = AppDateUtils.daysBetween(memberSince.toLocal(), today);
    if (dayIndex < 0 || dayIndex >= handoverDays) return null;
    final remaining = (handoverDays - dayIndex) / handoverDays;
    return (baseline.clamp(0, _maxScore) * remaining).round();
  }
}

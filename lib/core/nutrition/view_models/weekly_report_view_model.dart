import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/flow_category.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/models/weekly_metric.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class WeeklyReportViewModel extends ChangeNotifier {
  WeeklyReportViewModel(this._logService, DateTime date, this._goalService)
    : _weekStart = AppDateUtils.startOfWeek(date) {
    _days = _buildWeek(const NutritionLogs(foods: [], waters: []));
    _goalSubscription = _goalService.watch().listen(
      (goal) {
        _goal = goal;
        _days = [for (final day in _days) day.copyWithGoal(goal)];
        notifyListeners();
      },
      onError: (Object error) => debugPrint('weekly goal failed: $error'),
    );
    _subscription = _logService
        .watchLogs(_weekStart, AppDateUtils.addDays(_weekStart, _daysInWeek))
        .listen(
          (logs) {
            _days = _buildWeek(logs);
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('weekly report watch failed: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  static const int _daysInWeek = 7;
  static const double _streakThreshold = 0.7;

  final NutritionLogService _logService;
  final NutritionGoalService _goalService;
  NutritionGoal _goal = NutritionGoal.defaults;
  final DateTime _weekStart;
  late List<NutritionDay> _days;
  bool _isLoading = true;
  WeeklyMetric _metric = WeeklyMetric.calories;
  StreamSubscription<NutritionLogs>? _subscription;
  StreamSubscription<NutritionGoal>? _goalSubscription;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  List<NutritionDay> _buildWeek(NutritionLogs logs) => [
    for (var i = 0; i < _daysInWeek; i++)
      _dayFor(AppDateUtils.addDays(_weekStart, i), logs),
  ];

  NutritionDay _dayFor(DateTime date, NutritionLogs logs) => NutritionDay(
    date: date,
    goal: _goal,
    foodLogs: logs.foods
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, date))
        .toList(),
    waterLogs: logs.waters
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, date))
        .toList(),
  );

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  String get rangeLabel =>
      '${AppDateUtils.dayMonth(_weekStart)} — '
      '${AppDateUtils.dayMonth(AppDateUtils.addDays(_weekStart, _daysInWeek - 1))}';

  int get totalPoints =>
      _days.fold(0, (total, day) => total + day.totalFlowPoints);

  int get maxPoints => FlowCategory.dailyMax * _daysInWeek;

  String get totalPointsLabel => NutritionLabels.points(totalPoints);

  double get contributionProgress => totalPoints / maxPoints;

  String get contributionLabel =>
      '${NutritionLabels.percent(contributionProgress)} of max this week';

  List<ChartBar> get dailyPointBars => [
    for (final day in _days)
      ChartBar(
        label: AppDateUtils.shortWeekday(day.date),
        value: day.totalFlowPoints.toDouble(),
        valueLabel: NutritionLabels.points(day.totalFlowPoints),
        isHighlighted: AppDateUtils.isSameDay(day.date, _today),
      ),
  ];

  String get daysLoggedLabel =>
      '${_days.where((day) => day.hasFood).length}/$_daysInWeek';

  String get calorieStreakLabel =>
      '${_streak((day) => day.calories / _goal.calories)} d';

  String get proteinStreakLabel =>
      '${_streak((day) => day.proteinG / _goal.proteinG)} d';

  int _streak(double Function(NutritionDay day) ratioOf) {
    final today = _today;
    var streak = 0;
    for (final day in _days.reversed) {
      if (day.date.isAfter(today)) continue;
      if (ratioOf(day) >= _streakThreshold) {
        streak++;
      } else if (!AppDateUtils.isSameDay(day.date, today)) {
        break;
      }
    }
    return streak;
  }

  List<DayStatusItem> get dayStatuses => [
    for (final day in _days)
      DayStatusItem(
        label: AppDateUtils.shortWeekday(day.date),
        status: day.logStatus,
      ),
  ];

  WeeklyMetric get metric => _metric;

  double _metricValue(NutritionDay day) => switch (_metric) {
    WeeklyMetric.calories => day.calories,
    WeeklyMetric.protein => day.proteinG,
    WeeklyMetric.fiber => day.fiberG,
  };

  int get _metricDailyGoal => switch (_metric) {
    WeeklyMetric.calories => _goal.calories,
    WeeklyMetric.protein => _goal.proteinG,
    WeeklyMetric.fiber => _goal.fiberG,
  };

  String _formatMetric(double value) => _metric == WeeklyMetric.calories
      ? NutritionLabels.number(value)
      : NutritionLabels.grams(value);

  String get _metricUnit => _metric == WeeklyMetric.calories ? 'kcal' : 'g';

  List<ChartBar> get metricBars => [
    for (final day in _days)
      ChartBar(
        label: AppDateUtils.shortWeekday(day.date),
        value: _metricValue(day),
        valueLabel: _metric == WeeklyMetric.calories || !day.hasFood
            ? null
            : _formatMetric(_metricValue(day)),
        isHighlighted: AppDateUtils.isSameDay(day.date, _today),
      ),
  ];

  double get _metricTotal =>
      _days.fold(0, (total, day) => total + _metricValue(day));

  String get metricAverageLabel {
    final loggedDays = _days.where((day) => day.hasFood).length;
    final average = loggedDays == 0 ? 0.0 : _metricTotal / loggedDays;
    return '${_formatMetric(average)} avg';
  }

  String get metricGoalLabel =>
      'goal ${NumberFormatter.grouped(_metricDailyGoal)} $_metricUnit/day';

  String get metricTotalLabel => _formatMetric(_metricTotal);

  String get metricWeeklyGoalLabel =>
      _formatMetric((_metricDailyGoal * _daysInWeek).toDouble());

  double get metricProgress => _metricTotal / (_metricDailyGoal * _daysInWeek);

  int _weeklyPoints(FlowCategory category) =>
      _days.fold(0, (total, day) => total + day.pointsFor(category));

  List<FlowPointRow> get pointsBreakdown => [
    for (final category in FlowCategory.values)
      FlowPointRow(
        label: category.label,
        detail: 'max ${category.maxPerDay * _daysInWeek}/wk',
        pointsLabel: NutritionLabels.points(_weeklyPoints(category)),
        progress: _weeklyPoints(category) / (category.maxPerDay * _daysInWeek),
      ),
  ];

  String get tipMessage {
    FlowCategory? weakest;
    var largestGap = 0;
    for (final category in FlowCategory.values) {
      final gap =
          category.maxPerDay * _daysInWeek - _weeklyPoints(category);
      if (gap > largestGap) {
        largestGap = gap;
        weakest = category;
      }
    }
    if (weakest == null) {
      return 'A perfect week — every nutrition Flow Point earned. Keep it up!';
    }
    return '${weakest.habit} every day is the fastest way to grow your '
        'nutrition Flow contribution — worth up to '
        '+${weakest.maxPerDay * _daysInWeek} pts/week.';
  }

  void selectMetric(WeeklyMetric metric) {
    if (metric == _metric) return;
    _metric = metric;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }
}

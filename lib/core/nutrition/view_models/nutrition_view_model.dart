import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/nutrition/models/diet_plan.dart';
import 'package:floww/core/nutrition/models/flow_category.dart';
import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/services/diet_plan_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

enum NutritionDayStatus { past, today, future }

class NutritionViewModel extends ChangeNotifier {
  NutritionViewModel(this._logService, this._dietPlanService)
    : _selectedDate = AppDateUtils.dateOnly(DateTime.now()) {
    _watchSelectedDay();
    _recentSubscription = _logService.watchRecentFoodLogs().listen(
      (logs) {
        _recentLogs = logs;
        notifyListeners();
      },
      onError: (Object error) => debugPrint('recent food logs failed: $error'),
    );
    _dayRollover = DayRolloverTimer(_onNewDay);
    loadDietPlan();
  }

  static const int _selectableRangeDays = 365;
  static const int _weekdayReferenceDays = 6;
  static const int _recentFoodLimit = 10;
  static const int _excellentPoints = 20;
  static const int _greatPoints = 12;

  final NutritionLogService _logService;
  final DietPlanService _dietPlanService;
  final NutritionGoal goal = NutritionGoal.defaults;

  DateTime _selectedDate;
  late NutritionDay _day;
  bool _isLoading = true;
  String? _errorMessage;
  List<FoodLog> _recentLogs = const [];
  DietPlanProgress? _dietPlan;
  StreamSubscription<NutritionLogs>? _daySubscription;
  StreamSubscription<List<FoodLog>>? _recentSubscription;
  late final DayRolloverTimer _dayRollover;
  bool _disposed = false;

  DateTime get selectedDate => _selectedDate;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  DateTime get firstSelectableDate =>
      AppDateUtils.addDays(_today, -_selectableRangeDays);

  DateTime get lastSelectableDate =>
      AppDateUtils.addDays(_today, _selectableRangeDays);

  bool get canGoPrevious => _selectedDate.isAfter(firstSelectableDate);

  bool get canGoNext => _selectedDate.isBefore(lastSelectableDate);

  NutritionDayStatus get dayStatus {
    final today = _today;
    if (AppDateUtils.isSameDay(_selectedDate, today)) {
      return NutritionDayStatus.today;
    }
    return _selectedDate.isAfter(today)
        ? NutritionDayStatus.future
        : NutritionDayStatus.past;
  }

  NutritionDay get day => _day;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get canLog => dayStatus != NutritionDayStatus.past;

  bool get showDetails => dayStatus == NutritionDayStatus.today || _day.hasLogs;

  bool get showEmptyState => !_isLoading && !showDetails;

  bool get showStartTracking =>
      dayStatus == NutritionDayStatus.today && !_day.hasFood;

  bool get showFlowImpact => !canLog && _day.hasLogs;

  bool get showDietPlan =>
      dayStatus == NutritionDayStatus.today && _day.hasFood;

  bool get showRecentFoods => canLog && _recentLogs.isNotEmpty;

  String get titlePrefix => dayStatus == NutritionDayStatus.today
      ? 'Today\'s'
      : '${AppDateUtils.weekdayName(_selectedDate)}\'s';

  String get dateLabel => AppDateUtils.dayMonth(
    _selectedDate,
    withYear: _selectedDate.year != _today.year,
  );

  String get weekRangeLabel {
    final start = AppDateUtils.startOfWeek(_selectedDate);
    final end = AppDateUtils.endOfWeek(_selectedDate);
    return '${AppDateUtils.dayMonth(start)} — ${AppDateUtils.dayMonth(end)}';
  }

  String get _dayReference {
    final distance = AppDateUtils.daysBetween(_today, _selectedDate).abs();
    return distance <= _weekdayReferenceDays
        ? AppDateUtils.weekdayName(_selectedDate)
        : AppDateUtils.dayMonth(_selectedDate);
  }

  String get readOnlyLabel =>
      '${AppDateUtils.relativeDay(_selectedDate)} · Historical data (read-only)';

  String get emptyTitle => dayStatus == NutritionDayStatus.past
      ? 'Nothing logged'
      : 'Nothing logged yet';

  String get emptyMessage => switch (dayStatus) {
    NutritionDayStatus.future =>
      'This date is in the future. Plan your meals ahead or come back on '
          '$_dayReference to log your nutrition.',
    NutritionDayStatus.today =>
      'Scan your meal or tap Log Food to start tracking today\'s nutrition.',
    NutritionDayStatus.past =>
      'No meals were logged on $_dayReference. Past days are read-only so '
          'your Flow Points stay fair.',
  };

  String get tipTitle => switch (dayStatus) {
    NutritionDayStatus.future => 'Plan Ahead',
    NutritionDayStatus.today => 'Scan Tip',
    NutritionDayStatus.past => 'Stay Consistent',
  };

  String get tipMessage => switch (dayStatus) {
    NutritionDayStatus.future =>
      'Pre-logging meals for upcoming days helps you stay on track with your '
          'calorie and macro goals.',
    NutritionDayStatus.today =>
      'Snap your plate before you start eating. A full plate gives WAVE the '
          'most accurate portion estimate.',
    NutritionDayStatus.past =>
      'Logging every day keeps your weekly averages and WAVE insights '
          'accurate.',
  };

  String get calorieGoalLabel => NumberFormatter.grouped(goal.calories);

  String get proteinGoalLabel => '${goal.proteinG}g';

  String get carbsGoalLabel => '${goal.carbsG}g';

  String get fatsGoalLabel => '${goal.fatsG}g';

  String get caloriesConsumedLabel => NutritionLabels.number(_day.calories);

  String get caloriesRemainingLabel =>
      NutritionLabels.number(math.max(0, goal.calories - _day.calories));

  double get calorieProgress => _day.calories / goal.calories;

  String get calorieShareLabel =>
      '${NutritionLabels.percent(calorieProgress)} of goal';

  List<MacroProgressItem> get macros => [
    for (final macro in MacroNutrient.values)
      MacroProgressItem(
        macro: macro,
        amountLabel: NutritionLabels.number(_day.macroSplit.gramsOf(macro)),
        goalLabel: '/${_day.goalGramsOf(macro)}g',
        percentLabel: NutritionLabels.percent(_macroProgress(macro)),
        progress: _macroProgress(macro),
      ),
  ];

  double _macroProgress(MacroNutrient macro) =>
      _day.macroSplit.gramsOf(macro) / _day.goalGramsOf(macro);

  List<MicronutrientTileItem> get micronutrients => [
    MicronutrientTileItem(
      kind: MicronutrientKind.water,
      label: 'Water',
      valueLabel: NutritionLabels.liters(_day.waterMl),
      goalLabel: '/${NutritionLabels.liters(goal.waterMl.toDouble())}L',
      percentLabel: NutritionLabels.percent(_day.waterMl / goal.waterMl),
      progress: _day.waterMl / goal.waterMl,
    ),
    MicronutrientTileItem(
      kind: MicronutrientKind.fiber,
      label: 'Fiber',
      valueLabel: NutritionLabels.number(_day.fiberG),
      goalLabel: '/${goal.fiberG}g',
      percentLabel: NutritionLabels.percent(_day.fiberG / goal.fiberG),
      progress: _day.fiberG / goal.fiberG,
    ),
    MicronutrientTileItem(
      kind: MicronutrientKind.sugar,
      label: 'Sugar',
      valueLabel: NutritionLabels.number(_day.sugarG),
      goalLabel: '/${goal.sugarG}g',
      percentLabel: NutritionLabels.percent(_day.sugarG / goal.sugarG),
      progress: _day.sugarG / goal.sugarG,
      isOverLimit: _day.sugarG > goal.sugarG,
    ),
    MicronutrientTileItem(
      kind: MicronutrientKind.sodium,
      label: 'Sodium',
      valueLabel: NutritionLabels.number(_day.sodiumMg),
      goalLabel: '/${NumberFormatter.grouped(goal.sodiumMg)}mg',
      percentLabel: NutritionLabels.percent(_day.sodiumMg / goal.sodiumMg),
      progress: _day.sodiumMg / goal.sodiumMg,
      isOverLimit: _day.sodiumMg > goal.sodiumMg,
    ),
  ];

  List<MealBreakdownItem> get meals => [
    for (final meal in MealType.values) _mealItem(meal),
  ];

  MealBreakdownItem _mealItem(MealType meal) {
    final count = _day.logsFor(meal).length;
    final calories = _day.caloriesFor(meal);
    final share = _day.calories == 0 ? 0.0 : calories / _day.calories;
    final emptySubtitle = canLog
        ? '0 items · Tap to add food'
        : 'Nothing logged';
    return MealBreakdownItem(
      meal: meal,
      subtitle: count == 0
          ? emptySubtitle
          : NutritionLabels.count(count, 'item', 'items'),
      caloriesLabel: NutritionLabels.kcal(calories),
      shareLabel: NutritionLabels.percent(share),
      share: share,
      hasItems: count > 0,
    );
  }

  int get flowPoints => _day.totalFlowPoints;

  int get flowPointsMax => FlowCategory.dailyMax;

  String get flowPointsHeadline {
    if (flowPoints >= _excellentPoints) return 'Excellent';
    if (flowPoints >= _greatPoints) return 'Great';
    return flowPoints > 0 ? 'Good start' : '';
  }

  String get flowPointsMessage {
    final dayWord = dayStatus == NutritionDayStatus.today
        ? 'today'
        : 'that day';
    if (flowPoints == 0) {
      return canLog
          ? 'Log your first meal to start building your nutrition flow points.'
          : 'No nutrition flow points were earned that day.';
    }
    if (flowPoints >= _excellentPoints) {
      return 'You\'re making excellent nutritional choices $dayWord.';
    }
    if (flowPoints >= _greatPoints) {
      return 'You\'re on track — keep your macros balanced $dayWord.';
    }
    return 'Every meal you log adds more flow points.';
  }

  String get flowImpactMaxLabel => '+${FlowCategory.dailyMax} Flow per day';

  String get flowPointsInfoMessage =>
      'Your nutrition log earns Flow Points ($flowPoints/$flowPointsMax). '
      'Every meal you log brings you closer to your daily Flow Score goal. '
      'Above $_excellentPoints is excellent — keep it up!';

  String get flowPointsTotalLabel => NutritionLabels.points(flowPoints);

  List<FlowPointRow> get flowPointRows => [
    for (final category in FlowCategory.values)
      FlowPointRow(
        label: category.label,
        detail: _flowDetail(category),
        pointsLabel: NutritionLabels.points(_day.pointsFor(category)),
        progress: _day.pointsFor(category) / category.maxPerDay,
      ),
  ];

  String _flowDetail(FlowCategory category) => switch (category) {
    FlowCategory.calories =>
      '${NutritionLabels.number(_day.calories)} / '
          '${NumberFormatter.grouped(goal.calories)} kcal',
    FlowCategory.protein =>
      '${NutritionLabels.grams(_day.proteinG)} / ${goal.proteinG}g · '
          '${NutritionLabels.percent(_day.proteinG / goal.proteinG)}',
    FlowCategory.carbs =>
      '${NutritionLabels.grams(_day.carbsG)} / ${goal.carbsG}g',
    FlowCategory.fats => '${NutritionLabels.grams(_day.fatG)} / ${goal.fatsG}g',
    FlowCategory.water =>
      '${NutritionLabels.liters(_day.waterMl)} / '
          '${NutritionLabels.liters(goal.waterMl.toDouble())}L · '
          '${NutritionLabels.percent(_day.waterMl / goal.waterMl)}',
    FlowCategory.fiber =>
      '${NutritionLabels.grams(_day.fiberG)} / ${goal.fiberG}g',
    FlowCategory.mealTiming =>
      '${_day.loggedMeals.length} of ${MealType.values.length} meals logged',
    FlowCategory.sugar =>
      '${NutritionLabels.grams(_day.sugarG)} / ${goal.sugarG}g limit',
    FlowCategory.sodium =>
      '${NutritionLabels.milligrams(_day.sodiumMg)} / '
          '${NumberFormatter.grouped(goal.sodiumMg)}mg limit',
  };

  List<RecentFoodItem> get recentFoods {
    final seen = <String>{};
    final items = <RecentFoodItem>[];
    for (final log in _recentLogs) {
      final key = '${log.food.name}|${log.food.servingDescription}';
      if (!seen.add(key)) continue;
      items.add(
        RecentFoodItem(
          log: log,
          name: log.food.name,
          caloriesLabel: NutritionLabels.kcal(log.macros.calories),
        ),
      );
      if (items.length == _recentFoodLimit) break;
    }
    return items;
  }

  String relogMessage(RecentFoodItem item) =>
      'Added ${item.name} to ${item.meal.label}';

  String get dietPlanNextLabel {
    final plan = _dietPlan;
    if (plan == null) return 'Start your 30-day plan';
    if (plan.isFinished) return 'Plan complete';
    return 'Next: Day ${plan.currentDayNumber.clamp(1, DietPlan.lengthDays)}';
  }

  String get dietPlanDaysLabel {
    final plan = _dietPlan;
    if (plan == null) {
      return '${DietPlan.lengthDays} days · built from your goals';
    }
    return '${plan.completedDays.length}/${DietPlan.lengthDays} days done';
  }

  String get dietPlanPercentLabel =>
      NutritionLabels.percent(_dietPlan?.completion ?? 0);

  double get dietPlanProgress => _dietPlan?.completion ?? 0;

  void previousDay() {
    if (canGoPrevious) _setDate(AppDateUtils.addDays(_selectedDate, -1));
  }

  void nextDay() {
    if (canGoNext) _setDate(AppDateUtils.addDays(_selectedDate, 1));
  }

  void selectDate(DateTime date) => _setDate(AppDateUtils.dateOnly(date));

  Future<void> loadDietPlan() async {
    try {
      _dietPlan = await _dietPlanService.loadProgress(
        targetCalories: goal.calories,
      );
    } catch (e) {
      debugPrint('loadDietPlan failed: $e');
      _dietPlan = null;
    }
    notifyListeners();
  }

  Future<String?> relog(FoodLog source) async {
    if (!canLog) return null;
    _errorMessage = null;
    try {
      final now = DateTime.now();
      final id = _logService.newFoodLogId();
      await _logService.addFoodLog(
        FoodLog(
          food: source.food.copyWith(id: id, createdAt: now.toUtc()),
          mealType: source.mealType,
          loggedAt: AppDateUtils.atTimeOf(_selectedDate, now),
        ),
      );
      return id;
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<void> removeFoodLog(String id) async {
    try {
      await _logService.deleteFoodLog(id);
    } on NutritionLogException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  void _onNewDay() {
    final previousDay = AppDateUtils.addDays(_today, -1);
    if (AppDateUtils.isSameDay(_selectedDate, previousDay)) {
      _setDate(_today);
    } else {
      notifyListeners();
    }
    loadDietPlan();
  }

  void _setDate(DateTime date) {
    if (AppDateUtils.isSameDay(date, _selectedDate)) return;
    _selectedDate = date;
    _watchSelectedDay();
    notifyListeners();
  }

  void _watchSelectedDay() {
    _daySubscription?.cancel();
    final date = _selectedDate;
    _day = NutritionDay(date: date, goal: goal);
    _isLoading = true;
    _daySubscription = _logService
        .watchLogs(date, AppDateUtils.addDays(date, 1))
        .listen(
          (logs) {
            _day = NutritionDay(
              date: date,
              goal: goal,
              foodLogs: logs.foods,
              waterLogs: logs.waters,
            );
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('watch nutrition day failed: $error');
            _isLoading = false;
            _errorMessage = 'Could not load your nutrition logs.';
            notifyListeners();
          },
        );
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dayRollover.cancel();
    _daySubscription?.cancel();
    _recentSubscription?.cancel();
    super.dispose();
  }
}

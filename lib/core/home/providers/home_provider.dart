import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/core/flow_mode/providers/flow_mode_controller.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/habits/services/habit_service.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/services/daily_quote_service.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(
    this._service,
    this._builder,
    this._achievementsService,
    this._flowModeController, {
    MuscleMapService? muscleMapService,
    DailyQuoteService? quoteService,
  }) : _muscleMapService = muscleMapService ?? MuscleMapService(),
       _quoteService = quoteService ?? DailyQuoteService() {
    _flowModeController.resetSession();
    _greeting = _greetingForHour(DateTime.now().hour);
    _watchToday();
    _loadMuscleMap();
    _loadDailyQuote();
    _dayRollover = DayRolloverTimer(_onNewDay);
  }

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  final HomeService _service;
  final HomeSnapshotBuilder _builder;
  final AchievementsService _achievementsService;
  final FlowModeController _flowModeController;
  final MuscleMapService _muscleMapService;
  final DailyQuoteService _quoteService;
  DailyQuote? _dailyQuote;

  late final DayRolloverTimer _dayRollover;
  StreamSubscription<HomeRecords>? _subscription;
  HomeRecords _records = HomeRecords.empty;
  HomeSnapshot _snapshot = HomeSnapshot.empty;
  DateTime _date = AppDateUtils.dateOnly(DateTime.now());
  bool _isReady = false;
  bool _disposed = false;

  late String _greeting;

  String get greeting => _greeting;

  DailyQuote? get dailyQuote => _dailyQuote;

  Future<void> _loadDailyQuote() async {
    final quote = await _quoteService.today();
    if (_disposed || quote == null) return;
    _dailyQuote = quote;
    notifyListeners();
  }

  bool get isReady => _isReady;

  String get userName => _snapshot.userName;

  int get streakCount => _snapshot.streakCount;

  int get flowScorePercent => _snapshot.flowScorePercent;

  int get displayFlowScorePercent => _snapshot.displayFlowScorePercent;

  bool get hasActivityToday => _snapshot.todayFlowEntry?.hasActivity ?? false;

  String get recoveryLevel => _snapshot.recovery.levelLabel;

  bool get hasRecoveryData => _snapshot.recovery.hasData;

  AppThemeMode get todayMode => _snapshot.flowMode.mode;

  FlowScoreBreakdown get flowScoreBreakdown => _snapshot.flowScoreBreakdown;

  List<FlowScoreBoost> get flowScoreBoosts => _snapshot.flowScoreBoosts;

  FlowModeDetail get flowModeDetail => _snapshot.flowMode;

  RecoveryDetail get recoveryDetail => _snapshot.recovery;

  List<HabitItem> get habits => _snapshot.habits;

  WorkoutRecommendation? get workout => _snapshot.workout;

  CompletedWorkout? get completedWorkout => _snapshot.completedWorkout;

  NutritionSummary get nutrition => _snapshot.nutrition;

  TodayProgress get todayProgress => _snapshot.todayProgress;

  MuscleRecoveryData get muscleRecovery => _snapshot.muscleRecovery;

  MuscleMapTemplate? muscleMapOf(MuscleBodySide side) =>
      _muscleMapService.templateOf(side);

  String? get waveInsight => _snapshot.waveInsight;

  StreakSummary get streakSummary =>
      _achievementsService.streakSummaryOf(_records.flowHistory, date: _date);

  Future<void> _loadMuscleMap() async {
    try {
      await _muscleMapService.load();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('muscle map load failed: $e\n$stackTrace');
    }
  }

  void _onNewDay() {
    _greeting = _greetingForHour(DateTime.now().hour);
    _watchToday();
    _loadDailyQuote();
  }

  void _watchToday() {
    _subscription?.cancel();
    _date = AppDateUtils.dateOnly(DateTime.now());
    _subscription = _service
        .watchRecords(_date)
        .listen(
          _apply,
          onError: (Object error) => debugPrint('home watch failed: $error'),
        );
  }

  void _apply(HomeRecords records) {
    _records = records;
    _snapshot = _builder.build(records, date: _date);
    _isReady = true;
    notifyListeners();
    _flowModeController.reportScore(_snapshot.displayFlowScorePercent);
  }

  Future<void> toggleHabit(String id) async {
    final habits = HabitSnapshot.of(_records.habits).habitsFor(_date);
    final habit = habits.where((habit) => habit.id == id).firstOrNull;
    if (habit == null) return;

    final updated = [
      for (final entry in habits)
        if (entry.id == id) entry.toggled() else entry,
    ];

    try {
      await _service.saveHabitDay(_date, updated, changedIds: {id});
    } on HabitException catch (e) {
      debugPrint('Home habit toggle failed: ${e.message}');
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dayRollover.cancel();
    _subscription?.cancel();
    _flowModeController.resetSession();
    super.dispose();
  }
}

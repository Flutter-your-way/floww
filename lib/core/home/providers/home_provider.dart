import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/home_snapshot_builder.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(
    this._service,
    this._builder,
    this._achievementsService, {
    MuscleMapService? muscleMapService,
  }) : _muscleMapService = muscleMapService ?? MuscleMapService() {
    _greeting = _greetingForHour(DateTime.now().hour);
    _watchToday();
    _loadMuscleMap();
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
  final MuscleMapService _muscleMapService;

  late final DayRolloverTimer _dayRollover;
  StreamSubscription<HomeRecords>? _subscription;
  HomeRecords _records = HomeRecords.empty;
  HomeSnapshot _snapshot = HomeSnapshot.empty;
  DailyFlowEntry? _savedFlow;
  DateTime _date = AppDateUtils.dateOnly(DateTime.now());
  bool _isReady = false;
  bool _disposed = false;

  late String _greeting;

  String get greeting => _greeting;

  bool get isReady => _isReady;

  String get userName => _snapshot.userName;

  int get streakCount => _snapshot.streakCount;

  int get flowScorePercent => _snapshot.flowScorePercent;

  String? get recoveryLevel =>
      _snapshot.recovery.hasData ? _snapshot.recovery.levelLabel : null;

  AppThemeMode? get todayMode => _snapshot.flowMode?.mode;

  FlowScoreBreakdown get flowScoreBreakdown => _snapshot.flowScoreBreakdown;

  List<FlowScoreBoost> get flowScoreBoosts => _snapshot.flowScoreBoosts;

  FlowModeDetail? get flowModeDetail => _snapshot.flowMode;

  RecoveryDetail get recoveryDetail => _snapshot.recovery;

  List<HabitItem> get habits => _snapshot.habits;

  WorkoutRecommendation? get workout => _snapshot.workout;

  NutritionSummary get nutrition => _snapshot.nutrition;

  TodayProgress get todayProgress => _snapshot.todayProgress;

  MuscleRecoveryData get muscleRecovery => _snapshot.muscleRecovery;

  MuscleMapTemplate? muscleMapOf(MuscleBodySide side) =>
      _muscleMapService.templateOf(side);

  String? get waveInsight => _snapshot.waveInsight;

  StreakSummary get streakSummary => _achievementsService.streakSummaryOf(
    _records.flowHistory,
    date: _date,
  );

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
  }

  void _watchToday() {
    _subscription?.cancel();
    _date = AppDateUtils.dateOnly(DateTime.now());
    _savedFlow = null;
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
    unawaited(_persistFlow(_snapshot.todayFlowEntry));
  }

  Future<void> _persistFlow(DailyFlowEntry? entry) async {
    if (entry == null || !entry.hasActivity) return;

    final stored = _storedFlowFor(_date);
    if (stored != null && stored.sameValuesAs(entry)) return;

    final saved = _savedFlow;
    if (saved != null && saved.sameValuesAs(entry)) return;

    _savedFlow = entry;
    await _service.saveDailyFlow(entry);
  }

  DailyFlowEntry? _storedFlowFor(DateTime date) {
    for (final entry in _records.flowHistory) {
      if (AppDateUtils.isSameDay(entry.date, date)) return entry;
    }
    return null;
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
    super.dispose();
  }
}

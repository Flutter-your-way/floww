import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/program_goal.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/models/workout_history.dart';
import 'package:floww/core/workout/models/workout_shift_offer.dart';
import 'package:floww/core/workout/models/workout_tab.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_history_analyzer.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';
import 'package:floww/core/workout/services/workout_shift_service.dart';

enum WorkoutDayStatus { past, today, future }

enum WorkoutPrimaryAction { start, resume }

class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel(
    this._sessionService,
    this._planService,
    this._programService,
    this._catalogService,
  ) : _selectedDate = AppDateUtils.dateOnly(DateTime.now()),
      _shiftService = WorkoutShiftService(_planService) {
    _dayRollover = DayRolloverTimer(_onNewDay);
    _start();
  }

  static const int _selectableRangeDays = 365;
  static const int _weekdayReferenceDays = 6;
  static const int _heartRateAxisSteps = 4;
  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load your workouts.';
  static const Duration _clockTick = Duration(seconds: 1);
  static const int _historyMinWeeks = 8;
  static const int _historyMaxDays = 182;
  static const int _percent = 100;
  static const double _strongAdherence = 0.8;
  static const int _strongAdherenceMinPlanned = 3;
  static const String _allFilter = 'all';
  static const String _mineFilter = 'mine';

  final WorkoutSessionService _sessionService;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;
  final WorkoutShiftService _shiftService;

  StreamSubscription<List<WorkoutSessionEntity>>? _sessionSubscription;
  StreamSubscription<WorkoutStateEntity>? _stateSubscription;
  StreamSubscription<List<WorkoutProgramEntity>>? _programSubscription;
  StreamSubscription<WorkoutPlanEntity?>? _planSubscription;

  DateTime _selectedDate;
  DateChangeDirection _dateDirection = DateChangeDirection.forward;
  WorkoutTab _selectedTab = WorkoutTab.overview;
  bool _tabReverse = false;
  late final DayRolloverTimer _dayRollover;
  Timer? _clock;

  List<WorkoutSessionEntity> _sessions = const [];
  List<WorkoutProgramEntity> _programs = const [];
  WorkoutStateEntity _state = WorkoutStateEntity.empty;
  WorkoutPlanEntity? _plan;
  WorkoutShiftOffer? _shiftOffer;
  bool _isShifting = false;
  int _shiftRequest = 0;
  String _goalFilter = _allFilter;
  ProgramLevel? _levelFilter;
  List<WorkoutPlanEntity> _historyPlans = const [];
  List<Object?>? _historyCacheInputs;
  WorkoutHistoryOverviewItem? _historyCache;
  DateTime? _historyFrom;
  bool _historyLoaded = false;
  int _historyRequest = 0;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<WorkoutTab> get tabs => WorkoutTab.values;

  WorkoutTab get selectedTab => _selectedTab;

  bool get tabReverse => _tabReverse;

  DateTime get selectedDate => _selectedDate;

  DateChangeDirection get dateDirection => _dateDirection;

  DateTime get _today => AppDateUtils.dateOnly(DateTime.now());

  DateTime get firstSelectableDate =>
      AppDateUtils.addDays(_today, -_selectableRangeDays);

  DateTime get lastSelectableDate =>
      AppDateUtils.addDays(_today, _selectableRangeDays);

  bool get canGoPrevious => _selectedDate.isAfter(firstSelectableDate);

  bool get canGoNext => _selectedDate.isBefore(lastSelectableDate);

  WorkoutDayStatus get dayStatus {
    final today = _today;
    if (AppDateUtils.isSameDay(_selectedDate, today)) {
      return WorkoutDayStatus.today;
    }
    return _selectedDate.isAfter(today)
        ? WorkoutDayStatus.future
        : WorkoutDayStatus.past;
  }

  bool get showDateSelector => _selectedTab == WorkoutTab.overview;

  String get titlePrefix => !showDateSelector
      ? 'Your'
      : dayStatus == WorkoutDayStatus.today
      ? 'Today\'s'
      : '${AppDateUtils.weekdayName(_selectedDate)}\'s';

  String get dateLabel => AppDateUtils.dayMonth(
    _selectedDate,
    withYear: _selectedDate.year != _today.year,
  );

  Future<void> _start() async {
    try {
      await _catalogService.ensureSeeded();
    } on WorkoutException catch (error) {
      _onError(error);
      return;
    }

    _sessionSubscription = _sessionService.watchRecentSessions().listen((
      sessions,
    ) {
      _sessions = sessions;
      _isLoading = false;
      _errorMessage = null;
      _syncClock();
      notifyListeners();
      unawaited(_refreshShiftOffer());
      final loadedFrom = _historyFrom;
      if (loadedFrom == null || _historyStart.isBefore(loadedFrom)) {
        _reloadHistoryIfVisible();
      }
    }, onError: _onError);

    _stateSubscription = _programService.watchState().listen((state) {
      _state = state;
      notifyListeners();
      unawaited(_ensurePlan());
      unawaited(_refreshShiftOffer());
      _reloadHistoryIfVisible();
    }, onError: _onError);

    _programSubscription = _catalogService.watchPrograms().listen((programs) {
      _programs = programs;
      notifyListeners();
    }, onError: _onError);

    _watchPlan();
  }

  void _watchPlan() {
    _planSubscription?.cancel();
    _planSubscription = _planService.watchPlan(_selectedDate).listen((plan) {
      _plan = plan;
      notifyListeners();
      unawaited(_refreshShiftOffer());
    }, onError: _onError);
  }

  Future<void> _ensurePlan() async {
    final active = _state.activeProgram;
    if (active == null || dayStatus == WorkoutDayStatus.past) return;
    try {
      await _planService.ensurePlanFor(_selectedDate, activeProgram: active);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = error is WorkoutException ? error.message : _loadFailure;
    notifyListeners();
  }

  Future<void> retry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _sessionSubscription?.cancel();
    await _stateSubscription?.cancel();
    await _programSubscription?.cancel();
    await _planSubscription?.cancel();
    await _start();
    _reloadHistoryIfVisible();
  }

  DateTime get _historyStart {
    final today = _today;
    var start = AppDateUtils.addDays(
      AppDateUtils.startOfWeek(today),
      -DateTime.daysPerWeek * (_historyMinWeeks - 1),
    );
    for (final session in _sessions) {
      if (session.date.isBefore(start)) {
        start = AppDateUtils.startOfWeek(session.date);
      }
    }
    final floor = AppDateUtils.startOfWeek(
      AppDateUtils.addDays(today, -_historyMaxDays),
    );
    return start.isBefore(floor) ? floor : start;
  }

  void _reloadHistoryIfVisible() {
    if (_selectedTab == WorkoutTab.history) unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    final request = ++_historyRequest;
    final from = _historyStart;
    final end = AppDateUtils.addDays(AppDateUtils.endOfWeek(_today), 1);
    try {
      final plans = await _planService.loadScheduleBetween(
        from,
        end,
        activeProgram: _state.activeProgram,
      );
      if (request != _historyRequest) return;
      _historyPlans = plans;
    } on WorkoutException catch (error) {
      if (request != _historyRequest) return;
      _historyPlans = const [];
      _onError(error);
    }
    _historyFrom = from;
    _historyLoaded = true;
    notifyListeners();
  }

  WorkoutSessionEntity? get _selectedSession {
    for (final session in _sessions) {
      if (AppDateUtils.isSameDay(session.date, _selectedDate)) return session;
    }
    return null;
  }

  String? get overviewWorkoutId => _selectedSession?.id;

  WorkoutPrimaryAction? get primaryAction {
    if (dayStatus == WorkoutDayStatus.past) return null;
    final session = _selectedSession;
    if (session == null) return WorkoutPrimaryAction.start;
    if (session.isInProgress && dayStatus == WorkoutDayStatus.today) {
      return WorkoutPrimaryAction.resume;
    }
    return null;
  }

  String get primaryActionLabel => 'Start Workout';

  WorkoutSessionEntity? get _activeSession {
    final session = _selectedSession;
    if (session == null ||
        !session.isInProgress ||
        dayStatus != WorkoutDayStatus.today) {
      return null;
    }
    return session;
  }

  bool get isTimerPaused => _activeSession?.isTimerPaused ?? false;

  String get activeStatusLabel => isTimerPaused ? 'Paused' : 'In Progress';

  String get activeTimerLabel =>
      _clockLabel(_activeSession?.elapsedSecondsAt(DateTime.now()) ?? 0);

  Future<void> toggleTimer() async {
    final session = _activeSession;
    if (session == null) return;
    final now = DateTime.now();
    final updated = session.isTimerPaused
        ? session.resumedAt(now)
        : session.pausedAt(now);
    _sessions = [
      for (final entry in _sessions)
        if (entry.id == updated.id) updated else entry,
    ];
    _syncClock();
    notifyListeners();
    try {
      await _sessionService.saveTimer(updated);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void _syncClock() {
    final shouldTick = _activeSession?.isTimerRunning ?? false;
    if (!shouldTick) {
      _clock?.cancel();
      _clock = null;
      return;
    }
    _clock ??= Timer.periodic(_clockTick, (_) => notifyListeners());
  }

  String _clockLabel(int seconds) {
    final hours = seconds ~/ (_secondsPerMinute * _secondsPerMinute);
    final minutes = (seconds ~/ _secondsPerMinute) % _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    final clock =
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
    return hours > 0 ? '$hours:$clock' : clock;
  }

  bool get hasPlan => _plan != null;

  Future<void> _refreshShiftOffer() async {
    final request = ++_shiftRequest;
    try {
      final offer = await _shiftService.offerFor(
        date: _selectedDate,
        activeProgram: _state.activeProgram,
        sessions: _sessions,
        todayPlan: _plan,
        includePostpone: false,
      );
      if (request != _shiftRequest) return;
      _shiftOffer = offer;
      notifyListeners();
    } on WorkoutException catch (_) {
      return;
    }
  }

  WorkoutShiftOffer? get shiftOffer =>
      _selectedTab == WorkoutTab.overview ? _shiftOffer : null;

  bool get isShifting => _isShifting;

  Future<void> applyShift() async {
    final offer = _shiftOffer;
    final active = _state.activeProgram;
    if (offer == null || active == null || _isShifting) return;
    _isShifting = true;
    notifyListeners();
    try {
      await _shiftService.apply(offer, active);
      _shiftOffer = null;
    } on WorkoutException catch (error) {
      _onError(error);
    }
    _isShifting = false;
    notifyListeners();
    unawaited(_refreshShiftOffer());
  }

  WorkoutEmptyState get emptyState => switch (_selectedTab) {
    WorkoutTab.overview =>
      dayStatus == WorkoutDayStatus.future
          ? WorkoutEmptyState(
              icon: Icons.calendar_today,
              title: 'Nothing logged for this day',
              message:
                  'This is a future date. Come back on '
                  '${AppDateUtils.weekdayName(_selectedDate)} to log your '
                  'workout, or start a program to schedule one.',
            )
          : const WorkoutEmptyState(
              icon: Icons.directions_run,
              title: 'No workout logged yet',
              message:
                  'Start your first session to unlock training stats, muscle '
                  'tracking, and progress insights.',
            ),
    WorkoutTab.history => const WorkoutEmptyState(
      icon: Icons.pending_actions,
      title: 'No workout history',
      message:
          'Complete your first workout session and it\'ll appear here with '
          'full stats and training data.',
    ),
    WorkoutTab.programs => const WorkoutEmptyState(
      icon: Icons.pending_actions,
      title: 'No programs available',
      message:
          'Your program library is still syncing. Pull back in a moment to '
          'pick a weekly training plan.',
    ),
    WorkoutTab.exercises => const WorkoutEmptyState(
      icon: Icons.fitness_center,
      title: 'No exercises tracked',
      message:
          'Log a workout and every exercise you perform will show up here '
          'with your best sets.',
    ),
  };

  bool get showOverview =>
      _selectedTab == WorkoutTab.overview && overview != null;

  bool get isHistoryLoading =>
      _selectedTab == WorkoutTab.history && !_historyLoaded && !_isLoading;

  bool get showHistory => _selectedTab == WorkoutTab.history && history != null;

  bool get showEmptyState =>
      !_isLoading &&
      !isHistoryLoading &&
      _errorMessage == null &&
      !showOverview &&
      !showHistory &&
      !showPrograms &&
      !showExercises &&
      !showSuggestion;

  WorkoutHistoryAnalysis? get _historyAnalysis {
    final from = _historyFrom;
    if (!_historyLoaded || from == null) return null;
    return WorkoutHistoryAnalyzer.analyze(
      today: _today,
      from: from,
      plans: _historyPlans,
      sessions: _sessions,
      activeProgram: _state.activeProgram,
    );
  }

  WorkoutHistoryOverviewItem? get history {
    final inputs = [
      _historyLoaded,
      _historyFrom,
      _today,
      _historyPlans,
      _sessions,
      _state.activeProgram,
    ];
    final cachedInputs = _historyCacheInputs;
    if (cachedInputs != null && _sameInputs(cachedInputs, inputs)) {
      return _historyCache;
    }
    _historyCacheInputs = inputs;
    return _historyCache = _buildHistory();
  }

  static bool _sameInputs(List<Object?> a, List<Object?> b) {
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i]) && a[i] != b[i]) return false;
    }
    return true;
  }

  WorkoutHistoryOverviewItem? _buildHistory() {
    final analysis = _historyAnalysis;
    if (analysis == null) return null;
    final weeks = _historyWeeksOf(analysis.days);
    final consistency = _consistencyOf(analysis);
    if (weeks.isEmpty && consistency == null) return null;
    return WorkoutHistoryOverviewItem(consistency: consistency, weeks: weeks);
  }

  List<WorkoutHistoryWeekItem> _historyWeeksOf(List<WorkoutHistoryDay> days) {
    final today = _today;
    final weeks = <WorkoutHistoryWeekItem>[];
    DateTime? weekStart;
    var entries = <WorkoutHistoryEntryItem>[];
    var planned = 0;
    var done = 0;
    var workouts = 0;

    void closeWeek() {
      final start = weekStart;
      if (start == null || entries.isEmpty) return;
      weeks.add(
        WorkoutHistoryWeekItem(
          title: _weekTitleOf(start),
          summaryLabel: planned > 0
              ? '$done of $planned done'
              : workouts > 0
              ? '$workouts ${workouts == 1 ? 'workout' : 'workouts'}'
              : null,
          entries: entries,
        ),
      );
    }

    for (final day in days.reversed) {
      if (day.date.isAfter(today)) continue;
      final start = AppDateUtils.startOfWeek(day.date);
      if (weekStart == null || !AppDateUtils.isSameDay(start, weekStart)) {
        closeWeek();
        weekStart = start;
        entries = [];
        planned = 0;
        done = 0;
        workouts = 0;
      }
      final isCompleted = day.outcome == WorkoutDayOutcome.completed;
      if (isCompleted) workouts++;
      if (day.isPlanned && day.outcome != WorkoutDayOutcome.pending) {
        planned++;
        if (isCompleted) done++;
      }
      for (final session in day.sessions) {
        entries.add(WorkoutHistoryEntryItem.session(_historyItemOf(session)));
      }
      final missed = _missedItemOf(day);
      if (missed != null) entries.add(WorkoutHistoryEntryItem.missed(missed));
    }
    closeWeek();
    return weeks;
  }

  String _weekTitleOf(DateTime start) {
    final thisWeek = AppDateUtils.startOfWeek(_today);
    if (AppDateUtils.isSameDay(start, thisWeek)) return 'This week';
    if (AppDateUtils.isSameDay(
      start,
      AppDateUtils.addDays(thisWeek, -DateTime.daysPerWeek),
    )) {
      return 'Last week';
    }
    final end = AppDateUtils.endOfWeek(start);
    final withYear = end.year != _today.year;
    return start.month == end.month
        ? '${start.day} – ${AppDateUtils.dayMonth(end, withYear: withYear)}'
        : '${AppDateUtils.dayMonth(start)} – '
              '${AppDateUtils.dayMonth(end, withYear: withYear)}';
  }

  String _historyDayLabel(DateTime date) {
    final today = _today;
    if (AppDateUtils.isSameDay(date, today)) return 'Today';
    if (AppDateUtils.isSameDay(date, AppDateUtils.addDays(today, -1))) {
      return 'Yesterday';
    }
    return '${AppDateUtils.weekdayName(date)}, ${AppDateUtils.monthDay(date)}';
  }

  WorkoutHistoryItem _historyItemOf(WorkoutSessionEntity session) {
    final isToday = AppDateUtils.isSameDay(session.date, _today);
    return WorkoutHistoryItem(
      id: session.id,
      name: session.name,
      dateLabel: isToday
          ? 'Today · ${AppDateUtils.time(session.startedAt)}'
          : _historyDayLabel(session.date),
      effectLabel: session.trainingEffect.toStringAsFixed(1),
      metrics: [
        WorkoutMetricItem(
          icon: Icons.schedule,
          label: _durationLabel(session.elapsedSecondsAt(DateTime.now())),
        ),
        WorkoutMetricItem(
          icon: Icons.local_fire_department,
          label: '${NumberFormatter.grouped(session.caloriesKcal)} kcal',
        ),
        WorkoutMetricItem(
          icon: Icons.bar_chart,
          label: '${session.exerciseCount} exercises',
        ),
      ],
      statusLabel: session.isCompleted
          ? 'Completed'
          : isToday && session.isInProgress
          ? 'In Progress'
          : 'Unfinished',
      isHighlighted: isToday,
    );
  }

  MissedWorkoutItem? _missedItemOf(WorkoutHistoryDay day) {
    final plan = day.plan;
    final insight = day.insight;
    if (day.outcome != WorkoutDayOutcome.missed ||
        plan == null ||
        insight == null) {
      return null;
    }
    final advice = _missedAdviceOf(plan, insight);
    return MissedWorkoutItem(
      date: day.date,
      name: plan.name,
      dateLabel: _historyDayLabel(day.date),
      detailLabel: plan.programLabel.isNotEmpty
          ? plan.programLabel
          : plan.focus,
      metrics: [
        WorkoutMetricItem(
          icon: Icons.schedule,
          label: '${plan.durationMinutes} min',
        ),
        WorkoutMetricItem(
          icon: Icons.bar_chart,
          label: '${plan.exercises.length} exercises',
        ),
        WorkoutMetricItem(
          icon: Icons.layers_outlined,
          label: '${plan.totalSets} sets',
        ),
      ],
      adviceTitle: advice.title,
      advice: advice.message,
      adviceTone: advice.tone,
      musclesLabel: insight.muscles.join(' · '),
      exercises: [
        for (final entry in plan.exercises)
          MissedExerciseItem(
            name: entry.name,
            targetLabel: entry.isTimed
                ? '${entry.targetSets} × ${entry.targetReps}s'
                : '${entry.targetSets} × ${entry.targetReps}',
          ),
      ],
      goal: plan.goal.isNotEmpty ? plan.goal : plan.focus,
      actionLabel: insight.recovery == MissedRecovery.catchUp
          ? 'Do it today'
          : null,
    );
  }

  ({String title, String message, WorkoutStatTone tone}) _missedAdviceOf(
    WorkoutPlanEntity plan,
    MissedWorkoutInsight insight,
  ) {
    final muscles = insight.muscles;
    final musclesLabel = muscles.join(' & ');
    final keyExercise = insight.keyExercise;
    final coveredOn = insight.coveredOn;
    switch (insight.recovery) {
      case MissedRecovery.catchUp:
        return (
          title: 'Catch up today',
          message:
              'Shift your program back one day so ${plan.name} happens today '
              'and nothing gets lost.',
          tone: WorkoutStatTone.accent,
        );
      case MissedRecovery.covered:
        return (
          title: 'Already covered',
          message:
              'You trained ${muscles.first} '
              '${_relativeLabel(coveredOn ?? plan.date)}, so the main work '
              'of this session is done. No need to make it up.',
          tone: WorkoutStatTone.accent,
        );
      case MissedRecovery.prioritize:
        final focus = muscles.isEmpty
            ? 'This session'
            : '$musclesLabel ${muscles.length == 1 ? 'hasn\'t' : 'haven\'t'} '
                  'been trained since';
        final addition = keyExercise == null
            ? 'Add a few extra sets to your next session'
            : 'Add 2–3 sets of $keyExercise to your next session';
        return (
          title: 'Make it up this week',
          message: '$focus. $addition to keep progressing.',
          tone: WorkoutStatTone.warning,
        );
      case MissedRecovery.letGo:
        return (
          title: 'Let it go',
          message:
              'Too far back to make up — your program has already moved on. '
              'Focus on hitting this week\'s sessions.',
          tone: WorkoutStatTone.neutral,
        );
    }
  }

  String _relativeLabel(DateTime date) {
    final today = _today;
    if (AppDateUtils.isSameDay(date, today)) return 'today';
    if (AppDateUtils.isSameDay(date, AppDateUtils.addDays(today, -1))) {
      return 'yesterday';
    }
    return 'on ${AppDateUtils.weekdayName(date)}, ${AppDateUtils.monthDay(date)}';
  }

  WorkoutConsistencyItem? _consistencyOf(WorkoutHistoryAnalysis analysis) {
    final days = analysis.consistencyDays;
    final hasActivity = days.any(
      (day) => day.isPlanned || day.outcome == WorkoutDayOutcome.completed,
    );
    if (!hasActivity) return null;
    final consistency = analysis.consistency;
    final adherence = consistency.adherence;
    final today = _today;
    final marks = [for (final day in days) _markOf(day)];

    return WorkoutConsistencyItem(
      periodLabel: 'Last ${WorkoutHistoryAnalyzer.consistencyWeeks} weeks',
      headline: adherence == null
          ? '${consistency.workouts}'
          : '${(adherence * _percent).round()}%',
      caption: adherence == null
          ? consistency.workouts == 1
                ? 'workout logged'
                : 'workouts logged'
          : '${consistency.completed} of ${consistency.planned} planned '
                'sessions done',
      progress: adherence,
      stats: [
        WorkoutConsistencyStat(
          value: '${consistency.workouts}',
          label: 'Done',
          tone: WorkoutStatTone.accent,
        ),
        WorkoutConsistencyStat(
          value: '${consistency.missed}',
          label: 'Missed',
          tone: consistency.missed > 0
              ? WorkoutStatTone.alert
              : WorkoutStatTone.neutral,
        ),
        WorkoutConsistencyStat(
          value: '${consistency.streak}',
          label: 'Streak',
          tone: WorkoutStatTone.neutral,
        ),
      ],
      weekdayLabels: [
        for (final day in days.take(DateTime.daysPerWeek))
          AppDateUtils.shortWeekday(day.date).substring(0, 1),
      ],
      days: [
        for (var i = 0; i < days.length; i++)
          WorkoutDayMarkItem(
            label: '${days[i].date.day}',
            mark: marks[i],
            isToday: AppDateUtils.isSameDay(days[i].date, today),
          ),
      ],
      legend: [
        WorkoutDayMark.completed,
        WorkoutDayMark.missed,
        if (marks.contains(WorkoutDayMark.partial)) WorkoutDayMark.partial,
        if (marks.contains(WorkoutDayMark.planned)) WorkoutDayMark.planned,
      ],
      insight: _consistencyInsightOf(consistency),
    );
  }

  WorkoutDayMark _markOf(WorkoutHistoryDay day) => switch (day.outcome) {
    WorkoutDayOutcome.completed => WorkoutDayMark.completed,
    WorkoutDayOutcome.partial => WorkoutDayMark.partial,
    WorkoutDayOutcome.missed => WorkoutDayMark.missed,
    WorkoutDayOutcome.rest => WorkoutDayMark.rest,
    WorkoutDayOutcome.pending =>
      day.isPlanned ? WorkoutDayMark.planned : WorkoutDayMark.rest,
  };

  String? _consistencyInsightOf(WorkoutConsistency consistency) {
    final adherence = consistency.adherence;
    final weekday = consistency.mostMissedWeekday;
    if (consistency.missedInRow >= WorkoutHistoryAnalyzer.patternThreshold) {
      return '${consistency.missedInRow} sessions missed in a row. A shorter '
          'version of your next workout keeps the habit alive — momentum '
          'beats perfection.';
    }
    if (weekday != null) {
      final name = AppDateUtils.weekdayName(
        AppDateUtils.addDays(
          AppDateUtils.startOfWeek(_today),
          weekday - DateTime.monday,
        ),
      );
      return 'You\'ve missed ${consistency.mostMissedCount} ${name}s recently. '
          'If that day is usually busy, plan a lighter session or a rest day '
          'there instead.';
    }
    if (adherence != null &&
        adherence >= _strongAdherence &&
        consistency.planned >= _strongAdherenceMinPlanned) {
      return 'Strong consistency — ${(adherence * _percent).round()}% of '
          'planned sessions done. Keep this rhythm going.';
    }
    if (consistency.missed > 0) {
      return 'Tap a missed session to see what WAVE recommends doing about it.';
    }
    return null;
  }

  Future<void> catchUp(MissedWorkoutItem item) async {
    final active = _state.activeProgram;
    if (active == null || _isShifting) return;
    WorkoutPlanEntity? missed;
    for (final plan in _historyPlans) {
      if (AppDateUtils.isSameDay(plan.date, item.date)) missed = plan;
    }
    if (missed == null) return;
    _isShifting = true;
    notifyListeners();
    var shifted = false;
    try {
      await _shiftService.apply(
        WorkoutShiftOffer(kind: WorkoutShiftKind.catchUp, plan: missed),
        active,
      );
      _shiftOffer = null;
      shifted = true;
    } on WorkoutException catch (error) {
      _onError(error);
    }
    _isShifting = false;
    notifyListeners();
    if (!shifted) return;
    _setDate(_today);
    selectTab(WorkoutTab.overview);
    unawaited(_refreshShiftOffer());
  }

  bool get showSuggestion =>
      _selectedTab == WorkoutTab.overview &&
      overview == null &&
      suggestion != null;

  bool get showPrograms =>
      _selectedTab == WorkoutTab.programs && _programs.isNotEmpty;

  bool get showExercises => _selectedTab == WorkoutTab.exercises;

  WorkoutOverviewItem? get overview {
    final session = _selectedSession;
    if (session == null) return null;
    return WorkoutOverviewItem(
      summary: _summaryOf(session),
      trainingEffect: _trainingEffectOf(session),
      muscles: _musclesOf(session),
      heartRate: _heartRateOf(session),
      performance: _performanceOf(session),
    );
  }

  WorkoutSummaryItem _summaryOf(WorkoutSessionEntity session) {
    return WorkoutSummaryItem(
      name: session.name,
      exercisesLabel: _exercisesLabelOf(session),
      flowPointsLabel: '+ ${session.flowPoints} Flow points',
      statusLabel: session.isCompleted
          ? 'Completed'
          : session.isTimerPaused
          ? 'Paused'
          : 'In Progress',
      isCompleted: session.isCompleted,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'DURATION',
          value: _durationLabel(session.elapsedSecondsAt(DateTime.now())),
          unit: 'min',
        ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'VOLUME',
          value: NumberFormatter.grouped(session.volumeKg.round()),
          unit: 'kg',
        ),
        WorkoutStatItem(
          icon: Icons.local_fire_department,
          title: 'CALORIES',
          value: NumberFormatter.grouped(session.caloriesKcal),
          unit: 'kcal',
        ),
        WorkoutStatItem(
          icon: Icons.monitor_heart,
          title: 'AVG HEART RATE',
          value: session.averageHeartRate == null
              ? '—'
              : '${session.averageHeartRate}',
          unit: session.averageHeartRate == null ? '' : 'bpm',
        ),
      ],
    );
  }

  String _exercisesLabelOf(WorkoutSessionEntity session) {
    if (session.isInProgress) {
      final done = session.exercises.where((entry) => entry.isComplete).length;
      return '$done / ${session.exercises.length} Exercises done';
    }
    final count = session.exerciseCount;
    return '$count ${count == 1 ? 'Exercise' : 'Exercises'}';
  }

  TrainingEffectItem _trainingEffectOf(WorkoutSessionEntity session) {
    const total = WorkoutMetrics.effectSegments;
    final filled =
        (session.trainingEffect / WorkoutMetrics.maxTrainingEffect * total)
            .round()
            .clamp(0, total);
    return TrainingEffectItem(
      score: session.trainingEffect.toStringAsFixed(1),
      rating: WorkoutMetrics.effectRatingOf(session.trainingEffect),
      summary: WorkoutMetrics.effectSummaryOf(
        session.trainingEffect,
        session.muscleActivation,
      ),
      filledSegments: filled,
      totalSegments: total,
      recoveryLabel: 'Recovery Recommended',
      recoveryValue:
          '${WorkoutMetrics.recoveryHoursOf(session.trainingEffect)}h',
    );
  }

  List<MuscleFocusEntry> _musclesOf(WorkoutSessionEntity session) => [
    for (final muscle in session.muscleActivation)
      MuscleFocusEntry(
        name: muscle.name,
        shareLabel: '${(muscle.share * 100).round()}%',
        share: muscle.share,
      ),
  ];

  String get summaryInfoMessage =>
      '$titlePrefix overview: total volume, calories burned, and average '
      'heart rate from your logged session. Volume is the weight you lifted '
      'multiplied by the reps you completed across every set. Calories use '
      'your logged body weight and the intensity of each movement. Heart '
      'rate is read from Apple Health or Health Connect when connected.';

  String get trainingEffectInfoMessage =>
      'Training Effect (1–5) measures how much this session moved your '
      'fitness. It combines the sets you completed, how long you trained, '
      'and the intensity of the movements you chose. 1–2 = recovery, '
      '3 = maintaining, 4 = improving, 5 = highly impactful.';

  MuscleAnatomyItem? get anatomy {
    final session = _selectedSession;
    if (session == null || session.muscleActivation.isEmpty) return null;
    final activation = session.muscleActivation;
    return MuscleAnatomyItem(
      subtitle: '$titlePrefix activation map',
      muscles: [
        for (var i = 0; i < activation.length; i++)
          MuscleFocusEntry(
            name: activation[i].name,
            shareLabel: '${(activation[i].share * 100).round()}%',
            share: activation[i].share,
            highlight: i == 0 ? _highestActivationLabel : null,
          ),
      ],
      recoveryTip:
          'Primary muscles (${activation.first.name}) need '
          '${WorkoutMetrics.recoveryHoursOf(session.trainingEffect)}h to '
          'fully recover. Avoid targeting them again tomorrow.',
    );
  }

  String get _highestActivationLabel => dayStatus == WorkoutDayStatus.today
      ? 'Highest activation today'
      : 'Highest activation';

  HeartRateItem? _heartRateOf(WorkoutSessionEntity session) {
    final average = session.averageHeartRate;
    final peak = session.peakHeartRate;
    if (average == null || peak == null || session.heartRateSamples.isEmpty) {
      return null;
    }
    final totalMinutes = session.durationSeconds ~/ _secondsPerMinute;
    final step = totalMinutes / _heartRateAxisSteps;
    return HeartRateItem(
      stats: [
        HeartRateStatItem(
          value: '$average',
          unit: 'bpm',
          label: 'Average',
          tone: WorkoutStatTone.alert,
        ),
        HeartRateStatItem(
          value: '$peak',
          unit: 'bpm',
          label: 'Peak',
          tone: WorkoutStatTone.accent,
        ),
        HeartRateStatItem(
          value: '${_zoneOf(average, peak)}',
          unit: '/ 5',
          label: 'Zone',
          tone: WorkoutStatTone.ember,
        ),
      ],
      samples: [
        for (final sample in session.heartRateSamples) sample.toDouble(),
      ],
      axisLabels: [
        for (var i = 0; i < _heartRateAxisSteps; i++) '${(step * i).round()}m',
        '${totalMinutes}m',
      ],
    );
  }

  int _zoneOf(int average, int peak) {
    if (peak == 0) return 1;
    final ratio = average / peak;
    if (ratio < 0.6) return 1;
    if (ratio < 0.7) return 2;
    if (ratio < 0.8) return 3;
    if (ratio < 0.9) return 4;
    return 5;
  }

  PerformanceItem _performanceOf(WorkoutSessionEntity session) {
    return PerformanceItem(
      stats: [
        PerformanceStatItem(
          label: 'New PRs',
          value: '${session.personalRecords.length}',
          tone: WorkoutStatTone.accent,
        ),
        PerformanceStatItem(
          label: 'Exercises Completed',
          value: '${session.exerciseCount}',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Total Sets',
          value: '${session.totalSets}',
          tone: WorkoutStatTone.neutral,
        ),
        PerformanceStatItem(
          label: 'Total Reps',
          value: '${session.totalReps}',
          tone: WorkoutStatTone.neutral,
        ),
      ],
      records: [
        for (final record in session.personalRecords)
          PersonalRecordItem(
            label: '${record.glyph} ${record.exercise}',
            improvement: record.improvement,
          ),
      ],
    );
  }

  String _durationLabel(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final remainder = seconds % _secondsPerMinute;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  bool get isReadOnly => dayStatus == WorkoutDayStatus.past;

  bool get showReadOnlyBanner =>
      isReadOnly && _selectedTab == WorkoutTab.overview && overview != null;

  String get readOnlyLabel {
    final isYesterday = AppDateUtils.isSameDay(
      _selectedDate,
      AppDateUtils.addDays(_today, -1),
    );
    final distance = AppDateUtils.daysBetween(_today, _selectedDate).abs();
    final reference = isYesterday
        ? 'Yesterday'
        : distance <= _weekdayReferenceDays
        ? AppDateUtils.weekdayName(_selectedDate)
        : AppDateUtils.dayMonth(_selectedDate);
    return '$reference\'s session — historical data (read-only)';
  }

  String get suggestionTitle => dayStatus == WorkoutDayStatus.today
      ? 'Scheduled For Today'
      : 'Scheduled For ${AppDateUtils.weekdayName(_selectedDate)}';

  WorkoutSuggestionItem? get suggestion {
    final plan = _plan;
    if (plan == null || dayStatus == WorkoutDayStatus.past) return null;
    final active = _state.activeProgram;
    return WorkoutSuggestionItem(
      title: plan.name,
      durationLabel: '${plan.durationMinutes}m',
      intensityLabel: plan.focus,
      reasons: [
        if (active != null)
          '${active.name} · week ${active.weekAt(plan.date)} of '
              '${active.totalWeeks}',
        '${plan.exercises.length} exercises · ${plan.totalSets} sets',
        if (plan.goal.isNotEmpty) plan.goal,
      ],
    );
  }

  ActiveProgramItem? get activeProgram {
    final program = _state.activeProgram;
    if (program == null || program.totalWeeks == 0) return null;
    final week = program.weekAt(_today);
    final remaining = program.totalWeeks - week + 1;
    final progress = week / program.totalWeeks;
    return ActiveProgramItem(
      name: program.name,
      scheduleLabel:
          'Week $week of ${program.totalWeeks} · '
          '${program.daysPerWeek} days/week',
      statusLabel: 'ACTIVE',
      levelLabel: '${program.level} · $remaining weeks remaining',
      progressLabel: '${(progress * 100).round()}% complete',
      progress: progress,
    );
  }

  String? get activeProgramId => _state.activeProgram?.id;

  List<ProgramFilterItem<String>> get goalFilters => [
    ProgramFilterItem(
      value: _allFilter,
      label: 'All',
      isSelected: _goalFilter == _allFilter,
    ),
    if (_programs.any((program) => program.isCustom))
      ProgramFilterItem(
        value: _mineFilter,
        label: 'My programs',
        isSelected: _goalFilter == _mineFilter,
      ),
    for (final goal in ProgramGoal.values)
      if (_programs.any((program) => program.goal == goal))
        ProgramFilterItem(
          value: goal.id,
          label: goal.label,
          isSelected: _goalFilter == goal.id,
        ),
  ];

  List<ProgramFilterItem<ProgramLevel?>> get levelFilters => [
    ProgramFilterItem(
      value: null,
      label: 'Any level',
      isSelected: _levelFilter == null,
    ),
    for (final level in ProgramLevel.values)
      if (level != ProgramLevel.allLevels)
        ProgramFilterItem(
          value: level,
          label: level.label,
          isSelected: _levelFilter == level,
        ),
  ];

  void selectGoalFilter(String value) {
    if (value == _goalFilter) return;
    _goalFilter = value;
    notifyListeners();
  }

  void selectLevelFilter(ProgramLevel? value) {
    if (value == _levelFilter) return;
    _levelFilter = value;
    notifyListeners();
  }

  void showMyPrograms() {
    _goalFilter = _mineFilter;
    _levelFilter = null;
    notifyListeners();
  }

  bool _matchesFilters(WorkoutProgramEntity program) {
    final goalMatches = switch (_goalFilter) {
      _allFilter => true,
      _mineFilter => program.isCustom,
      _ => program.goal.id == _goalFilter,
    };
    final level = ProgramLevel.fromLabel(program.level);
    final levelMatches =
        _levelFilter == null ||
        level == ProgramLevel.allLevels ||
        level == _levelFilter;
    return goalMatches && levelMatches;
  }

  String get programsCountLabel {
    final count = programs.length;
    return '$count ${count == 1 ? 'program' : 'programs'}';
  }

  String get programsEmptyMessage =>
      'No programs match these filters. Try another goal or level, or build '
      'your own.';

  ProgramStartSetup? programStartSetupFor(String id) {
    final program = _programById(id);
    if (program == null) return null;
    return ProgramStartSetup(
      programId: program.id,
      name: program.name,
      dayWeekdays: [for (final day in program.days) day.weekday],
      weeks: program.weeks,
    );
  }

  List<int> _weekdaysOf(WorkoutProgramEntity program) {
    final active = _state.activeProgram;
    if (active != null &&
        active.id == program.id &&
        active.weekdays.length == program.days.length) {
      return active.weekdays;
    }
    return [for (final day in program.days) day.weekday];
  }

  ProgramDetailItem? programDetailFor(String id) {
    final program = _programById(id);
    if (program == null) return null;
    final active = _state.activeProgram;
    final isActive = active?.id == program.id;
    final weekdays = _weekdaysOf(program);
    final order = [for (var i = 0; i < program.days.length; i++) i]
      ..sort((a, b) => weekdays[a].compareTo(weekdays[b]));
    final anchor = AppDateUtils.startOfWeek(_today);
    return ProgramDetailItem(
      id: program.id,
      name: program.name,
      description: program.description,
      icon: program.goal.icon,
      isActive: isActive,
      isCustom: program.isCustom,
      schedule: [
        for (final index in order)
          ProgramScheduleItem(
            weekdayLabel: AppDateUtils.shortWeekday(
              AppDateUtils.addDays(anchor, weekdays[index] - DateTime.monday),
            ).toUpperCase(),
            name: program.days[index].name,
            detail:
                '${program.days[index].focus} · '
                '${program.days[index].exercises.length} exercises · '
                '${program.days[index].durationMinutes} min',
          ),
      ],
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'Duration',
          value: '${program.weeks}',
          unit: 'weeks',
        ),
        WorkoutStatItem(
          icon: Icons.track_changes,
          title: 'Frequency',
          value: '${program.sessionsPerWeek}x',
          unit: '/ week',
        ),
        WorkoutStatItem(
          icon: Icons.bar_chart,
          title: 'Level',
          value: program.level,
          unit: '',
        ),
      ],
      warning: active == null || isActive
          ? null
          : 'Starting this program replaces ${active.name} and '
                'reschedules your upcoming sessions.',
    );
  }

  List<ProgramItem> get programs {
    final activeId = _state.activeProgram?.id;
    final filtered =
        [
          for (final program in _programs)
            if (_matchesFilters(program)) program,
        ]..sort((a, b) {
          final activeOrder = (b.id == activeId ? 1 : 0).compareTo(
            a.id == activeId ? 1 : 0,
          );
          if (activeOrder != 0) return activeOrder;
          final customOrder = (b.isCustom ? 1 : 0).compareTo(
            a.isCustom ? 1 : 0,
          );
          if (customOrder != 0) return customOrder;
          return a.name.compareTo(b.name);
        });
    final anchor = AppDateUtils.startOfWeek(_today);
    return [
      for (final program in filtered)
        ProgramItem(
          id: program.id,
          name: program.name,
          description: program.description,
          icon: program.goal.icon,
          metaLabel:
              '${program.level} · ${program.weeks} '
              '${program.weeks == 1 ? 'week' : 'weeks'}',
          scheduleLabel:
              '${program.sessionsPerWeek}x / week · '
              '~${program.averageMinutes} min',
          weekdays: [
            for (var i = 0; i < DateTime.daysPerWeek; i++)
              ProgramWeekdayItem(
                label: AppDateUtils.shortWeekday(
                  AppDateUtils.addDays(anchor, i),
                ).substring(0, 1),
                isTraining: _weekdaysOf(program).contains(DateTime.monday + i),
              ),
          ],
          badgeLabel: program.id == activeId
              ? 'Active'
              : program.isCustom
              ? 'Custom'
              : null,
          isActive: program.id == activeId,
        ),
    ];
  }

  WorkoutProgramEntity? _programById(String id) {
    for (final program in _programs) {
      if (program.id == id) return program;
    }
    return null;
  }

  Future<void> startProgram(String id, ProgramStartConfig config) async {
    final program = _programById(id);
    if (program == null) return;
    try {
      final active = _programService.activeEntryFor(
        program,
        startDate: config.startDate,
        weeks: config.weeks,
        weekdays: config.weekdays,
      );
      await _planService.scheduleProgram(
        program,
        active,
        from: _today,
        saveActive: true,
      );
      _setDate(_today);
      selectTab(WorkoutTab.overview);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  String deleteProgramTitle(ProgramDetailItem detail) =>
      'Delete ${detail.name}?';

  String deleteProgramMessage(ProgramDetailItem detail) => detail.isActive
      ? 'This also stops the program and clears your upcoming sessions. '
            'Workouts you already logged stay in your history.'
      : 'This removes the program. Workouts you already logged stay in your '
            'history.';

  String stopProgramTitle(ProgramDetailItem detail) => 'Stop ${detail.name}?';

  String get stopProgramMessage =>
      'Your upcoming planned sessions will be cleared. Workouts you already '
      'logged stay in your history, and you can start any program again.';

  Future<void> stopProgram() async {
    try {
      await _planService.clearUpcoming(_today, stopProgram: true);
      _plan = null;
      notifyListeners();
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  Future<void> deleteProgram(String id) async {
    final program = _programById(id);
    if (program == null || !program.isCustom) return;
    try {
      if (_state.activeProgram?.id == id) await stopProgram();
      await _catalogService.deleteProgram(id);
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void selectTab(WorkoutTab tab) {
    if (tab == _selectedTab) return;
    _tabReverse = tab.index < _selectedTab.index;
    _selectedTab = tab;
    notifyListeners();
    _reloadHistoryIfVisible();
  }

  void previousDay() {
    if (canGoPrevious) _setDate(AppDateUtils.addDays(_selectedDate, -1));
  }

  void nextDay() {
    if (canGoNext) _setDate(AppDateUtils.addDays(_selectedDate, 1));
  }

  void selectDate(DateTime date) => _setDate(AppDateUtils.dateOnly(date));

  void _onNewDay() {
    final previousDay = AppDateUtils.addDays(_today, -1);
    if (AppDateUtils.isSameDay(_selectedDate, previousDay)) {
      _setDate(_today);
    } else {
      notifyListeners();
    }
    _reloadHistoryIfVisible();
  }

  void _setDate(DateTime date) {
    if (AppDateUtils.isSameDay(date, _selectedDate)) return;
    _dateDirection = date.isAfter(_selectedDate)
        ? DateChangeDirection.forward
        : DateChangeDirection.backward;
    _selectedDate = date;
    _plan = null;
    _shiftOffer = null;
    _syncClock();
    notifyListeners();
    _watchPlan();
    unawaited(_ensurePlan());
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dayRollover.cancel();
    _clock?.cancel();
    _sessionSubscription?.cancel();
    _stateSubscription?.cancel();
    _programSubscription?.cancel();
    _planSubscription?.cancel();
    super.dispose();
  }
}

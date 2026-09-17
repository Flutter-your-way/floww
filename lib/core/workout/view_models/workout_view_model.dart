import 'dart:async';

import 'package:flutter/material.dart';

import 'package:floww/config/entities/workout_plan_entity.dart';
import 'package:floww/config/entities/workout_program_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/workout_tab.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/services/workout_catalog_service.dart';
import 'package:floww/core/workout/services/workout_firestore.dart';
import 'package:floww/core/workout/services/workout_metrics.dart';
import 'package:floww/core/workout/services/workout_plan_service.dart';
import 'package:floww/core/workout/services/workout_program_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

enum WorkoutDayStatus { past, today, future }

class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel(
    this._sessionService,
    this._planService,
    this._programService,
    this._catalogService,
  ) : _selectedDate = AppDateUtils.dateOnly(DateTime.now()) {
    _dayRollover = DayRolloverTimer(_onNewDay);
    _start();
  }

  static const int _selectableRangeDays = 365;
  static const int _weekdayReferenceDays = 6;
  static const int _heartRateAxisSteps = 4;
  static const int _secondsPerMinute = 60;
  static const String _loadFailure = 'Could not load your workouts.';

  final WorkoutSessionService _sessionService;
  final WorkoutPlanService _planService;
  final WorkoutProgramService _programService;
  final WorkoutCatalogService _catalogService;

  StreamSubscription<List<WorkoutSessionEntity>>? _sessionSubscription;
  StreamSubscription<WorkoutStateEntity>? _stateSubscription;
  StreamSubscription<List<WorkoutProgramEntity>>? _programSubscription;
  StreamSubscription<WorkoutPlanEntity?>? _planSubscription;

  DateTime _selectedDate;
  DateChangeDirection _dateDirection = DateChangeDirection.forward;
  WorkoutTab _selectedTab = WorkoutTab.overview;
  late final DayRolloverTimer _dayRollover;

  List<WorkoutSessionEntity> _sessions = const [];
  List<WorkoutProgramEntity> _programs = const [];
  WorkoutStateEntity _state = WorkoutStateEntity.empty;
  WorkoutPlanEntity? _plan;
  bool _isLoading = true;
  bool _disposed = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<WorkoutTab> get tabs => WorkoutTab.values;

  WorkoutTab get selectedTab => _selectedTab;

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

  String get titlePrefix => dayStatus == WorkoutDayStatus.today
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
      notifyListeners();
    }, onError: _onError);

    _stateSubscription = _programService.watchState().listen((state) {
      _state = state;
      notifyListeners();
      unawaited(_ensurePlan());
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
  }

  WorkoutSessionEntity? get _selectedSession {
    for (final session in _sessions) {
      if (AppDateUtils.isSameDay(session.date, _selectedDate)) return session;
    }
    return null;
  }

  String? get overviewWorkoutId => _selectedSession?.id;

  bool get hasPlan => _plan != null;

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

  bool get showHistory =>
      _selectedTab == WorkoutTab.history && historySessions.isNotEmpty;

  bool get showEmptyState =>
      !_isLoading &&
      _errorMessage == null &&
      !showOverview &&
      !showHistory &&
      !showPrograms &&
      !showExercises &&
      !showSuggestion;

  List<WorkoutHistoryItem> get historySessions => [
    for (final session in _sessions)
      WorkoutHistoryItem(
        id: session.id,
        name: session.name,
        dateLabel: AppDateUtils.isSameDay(session.startedAt, _today)
            ? 'Today · ${AppDateUtils.time(session.startedAt)}'
            : AppDateUtils.monthDay(session.startedAt),
        effectLabel: session.trainingEffect.toStringAsFixed(1),
        metrics: [
          WorkoutMetricItem(
            icon: Icons.schedule,
            label: _durationLabel(session.durationSeconds),
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
        statusLabel: session.isCompleted ? 'Completed' : 'In Progress',
        isHighlighted: AppDateUtils.isSameDay(session.startedAt, _today),
      ),
  ];

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
      exercisesLabel:
          '${session.exerciseCount} '
          '${session.exerciseCount == 1 ? 'Exercise' : 'Exercises'}',
      flowPointsLabel: '+ ${session.flowPoints} Flow points',
      statusLabel: session.isCompleted ? 'Completed' : 'In Progress',
      isCompleted: session.isCompleted,
      stats: [
        WorkoutStatItem(
          icon: Icons.schedule,
          title: 'DURATION',
          value: _durationLabel(session.durationSeconds),
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
          tone: WorkoutStatTone.warning,
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

  ProgramDetailItem? programDetailFor(String id) {
    final program = _programById(id);
    if (program == null) return null;
    return ProgramDetailItem(
      id: program.id,
      name: program.name,
      description: program.description,
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
      warning: _state.activeProgram == null
          ? null
          : 'Starting this program replaces ${_state.activeProgram!.name} and '
                'reschedules your upcoming sessions.',
      startLabel: 'Start ${program.name}',
    );
  }

  List<ProgramItem> get programs => [
    for (final program in _programs)
      ProgramItem(
        id: program.id,
        name: program.name,
        detail:
            '${program.level} · ${program.weeks} week '
            '(${program.sessionsPerWeek}x/week)',
      ),
  ];

  WorkoutProgramEntity? _programById(String id) {
    for (final program in _programs) {
      if (program.id == id) return program;
    }
    return null;
  }

  Future<void> startProgram(String id) async {
    final program = _programById(id);
    if (program == null) return;
    try {
      final active = await _programService.startProgram(program);
      await _planService.scheduleProgram(program, active);
      _selectedTab = WorkoutTab.overview;
      notifyListeners();
    } on WorkoutException catch (error) {
      _onError(error);
    }
  }

  void selectTab(WorkoutTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
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
  }

  void _setDate(DateTime date) {
    if (AppDateUtils.isSameDay(date, _selectedDate)) return;
    _dateDirection = date.isAfter(_selectedDate)
        ? DateChangeDirection.forward
        : DateChangeDirection.backward;
    _selectedDate = date;
    _plan = null;
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
    _sessionSubscription?.cancel();
    _stateSubscription?.cancel();
    _programSubscription?.cancel();
    _planSubscription?.cancel();
    super.dispose();
  }
}

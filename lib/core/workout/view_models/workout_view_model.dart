import 'package:flutter/material.dart';

import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/config/utils/formatters/number_formatter.dart';
import 'package:floww/core/workout/models/workout_tab.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/models/workout_session.dart';
import 'package:floww/core/workout/services/workout_service.dart';

enum WorkoutDayStatus { past, today, future }

class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel(this._service)
    : _selectedDate = AppDateUtils.dateOnly(DateTime.now()) {
    _dayRollover = DayRolloverTimer(_onNewDay);
  }

  static const int _selectableRangeDays = 365;
  static const int _weekdayReferenceDays = 6;
  static const int _heartRateAxisSteps = 4;
  static const int _secondsPerMinute = 60;

  final WorkoutService _service;

  DateTime _selectedDate;
  DateChangeDirection _dateDirection = DateChangeDirection.forward;
  WorkoutTab _selectedTab = WorkoutTab.overview;
  late final DayRolloverTimer _dayRollover;
  bool _disposed = false;

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

  WorkoutEmptyState get emptyState => switch (_selectedTab) {
    WorkoutTab.overview =>
      dayStatus == WorkoutDayStatus.future
          ? WorkoutEmptyState(
              icon: Icons.calendar_today,
              title: 'No workout logged yet',
              message:
                  'This is a future date. Come back on '
                  '${AppDateUtils.weekdayName(_selectedDate)} to log your '
                  'workout, or schedule one now.',
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
      title: 'No active program',
      message:
          'Choose a structured program below to follow a weekly training plan '
          'with progressive overload.',
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
      !showOverview && !showHistory && !showPrograms && !showExercises;

  List<WorkoutHistoryItem> get historySessions => [
    for (final entry in _service.loadHistoryFor(_selectedDate))
      WorkoutHistoryItem(
        id: entry.id,
        name: entry.name,
        dateLabel: AppDateUtils.isSameDay(entry.performedAt, _today)
            ? 'Today · ${AppDateUtils.time(entry.performedAt)}'
            : AppDateUtils.monthDay(entry.performedAt),
        effectLabel: entry.trainingEffect.toStringAsFixed(1),
        metrics: [
          WorkoutMetricItem(
            icon: Icons.schedule,
            label: _durationLabel(entry.durationSeconds),
          ),
          WorkoutMetricItem(
            icon: Icons.local_fire_department,
            label: '${NumberFormatter.grouped(entry.calories)} kcal',
          ),
          WorkoutMetricItem(
            icon: Icons.bar_chart,
            label: '${entry.exerciseCount} exercises',
          ),
        ],
        statusLabel: entry.isCompleted ? 'Completed' : null,
        isHighlighted: AppDateUtils.isSameDay(entry.performedAt, _today),
      ),
  ];

  String? get overviewWorkoutId {
    final entries = _service.loadHistoryFor(_selectedDate);
    if (entries.isEmpty) return null;
    for (final entry in entries) {
      if (AppDateUtils.isSameDay(entry.performedAt, _selectedDate)) {
        return entry.id;
      }
    }
    return entries.first.id;
  }

  bool get showSuggestion =>
      _selectedTab == WorkoutTab.overview &&
      overview == null &&
      suggestion != null;

  bool get showPrograms => _selectedTab == WorkoutTab.programs;

  bool get showExercises => _selectedTab == WorkoutTab.exercises;

  WorkoutOverviewItem? get overview {
    final session = _service.completedSessionFor(_selectedDate);
    if (session == null || dayStatus == WorkoutDayStatus.future) return null;
    return WorkoutOverviewItem(
      summary: _summaryOf(session),
      trainingEffect: _trainingEffectOf(session),
      muscles: _musclesOf(session),
      heartRate: _heartRateOf(session),
      performance: _performanceOf(session),
    );
  }

  WorkoutSummaryItem _summaryOf(WorkoutSession session) {
    return WorkoutSummaryItem(
      name: session.name,
      exercisesLabel: '${session.exerciseCount} Exercises',
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
          value: NumberFormatter.grouped(session.volumeKg),
          unit: 'kg',
        ),
        WorkoutStatItem(
          icon: Icons.local_fire_department,
          title: 'CALORIES',
          value: NumberFormatter.grouped(session.calories),
          unit: 'kcal',
        ),
        WorkoutStatItem(
          icon: Icons.monitor_heart,
          title: 'AVG HEART RATE',
          value: '${session.averageHeartRate}',
          unit: 'bpm',
        ),
      ],
    );
  }

  TrainingEffectItem _trainingEffectOf(WorkoutSession session) {
    final total = session.trainingEffectScale.round();
    final filled =
        (session.trainingEffect / session.trainingEffectScale * total)
            .round()
            .clamp(0, total);
    return TrainingEffectItem(
      score: session.trainingEffect.toStringAsFixed(1),
      rating: session.trainingEffectRating,
      summary: session.trainingEffectSummary,
      filledSegments: filled,
      totalSegments: total,
      recoveryLabel: 'Recovery Recommended',
      recoveryValue: '${session.recoveryHours}h',
    );
  }

  List<MuscleFocusEntry> _musclesOf(WorkoutSession session) => [
    for (final muscle in session.muscleActivation)
      MuscleFocusEntry(
        name: muscle.name,
        shareLabel: '${(muscle.share * 100).round()}%',
        share: muscle.share,
      ),
  ];

  String get summaryInfoMessage =>
      '$titlePrefix overview: total volume, calories burned, and average '
      'heart rate from your completed session. Volume is calculated as total '
      'weight × total reps across all sets.';

  String get trainingEffectInfoMessage =>
      'Training Effect (1–5) measures how much your workout improves your '
      'fitness. 1–2 = recovery/easy, 3 = maintaining, 4 = improving, '
      '5 = highly impactful. Calculated from heart rate, duration, and '
      'intensity.';

  MuscleAnatomyItem? get anatomy {
    final session = _service.completedSessionFor(_selectedDate);
    if (session == null || dayStatus == WorkoutDayStatus.future) return null;
    final activation = [...session.muscleActivation]
      ..sort((a, b) => b.share.compareTo(a.share));
    if (activation.isEmpty) return null;
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
          '${session.muscleRecoveryMinHours}–${session.muscleRecoveryMaxHours}h '
          'to fully recover. Avoid targeting them again tomorrow.',
    );
  }

  String get _highestActivationLabel => dayStatus == WorkoutDayStatus.today
      ? 'Highest activation today'
      : 'Highest activation';

  HeartRateItem _heartRateOf(WorkoutSession session) {
    final totalMinutes = session.durationSeconds ~/ _secondsPerMinute;
    final step = totalMinutes / _heartRateAxisSteps;
    return HeartRateItem(
      stats: [
        HeartRateStatItem(
          value: '${session.averageHeartRate}',
          unit: 'bpm',
          label: 'Average',
          tone: WorkoutStatTone.alert,
        ),
        HeartRateStatItem(
          value: '${session.peakHeartRate}',
          unit: 'bpm',
          label: 'Peak',
          tone: WorkoutStatTone.accent,
        ),
        HeartRateStatItem(
          value: '${session.heartRateZone}',
          unit: '/ ${session.heartRateZoneCount}',
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

  PerformanceItem _performanceOf(WorkoutSession session) {
    return PerformanceItem(
      stats: [
        PerformanceStatItem(
          label: 'New PRs',
          value: '${session.newPersonalRecords}',
          tone: WorkoutStatTone.warning,
        ),
        PerformanceStatItem(
          label: 'Exercises Completed',
          value: '${session.exercisesCompleted}',
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
      ? 'Suggested For Today'
      : 'Suggested For ${AppDateUtils.weekdayName(_selectedDate)}';

  WorkoutSuggestionItem? get suggestion {
    if (dayStatus == WorkoutDayStatus.past) return null;
    final suggestion = _service.suggestionFor(_selectedDate);
    if (suggestion == null) return null;
    return WorkoutSuggestionItem(
      title: suggestion.title,
      durationLabel: '${suggestion.durationMinutes}m',
      intensityLabel: suggestion.intensity,
      reasons: suggestion.reasons,
    );
  }

  ActiveProgramItem? get activeProgram {
    final program = _service.loadActiveProgram();
    if (program == null) return null;
    final remaining = program.totalWeeks - program.currentWeek + 1;
    final progress = program.currentWeek / program.totalWeeks;
    return ActiveProgramItem(
      name: program.name,
      scheduleLabel:
          'Week ${program.currentWeek} of ${program.totalWeeks} · '
          '${program.daysPerWeek} days/week',
      statusLabel: 'ACTIVE',
      levelLabel: '${program.level} · $remaining weeks remaining',
      progressLabel: '${(progress * 100).round()}% complete',
      progress: progress,
    );
  }

  ProgramDetailItem? programDetailFor(String id) {
    final program = _service.programById(id);
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
      warning: _service.loadActiveProgram() == null
          ? null
          : 'Starting this program will replace your current active program. '
                'Your progress will be reset.',
      startLabel: 'Start ${program.name}',
    );
  }

  List<ProgramItem> get programs => [
    for (final program in _service.loadPrograms())
      ProgramItem(
        id: program.id,
        name: program.name,
        detail:
            '${program.level} · ${program.weeks} week '
            '(${program.sessionsPerWeek}x/week)',
      ),
  ];

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
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _dayRollover.cancel();
    super.dispose();
  }
}

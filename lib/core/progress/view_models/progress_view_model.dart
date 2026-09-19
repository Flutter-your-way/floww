import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/progress_state_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/progress/services/progress_snapshot_builder.dart';

class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel(
    this._service, {
    this._builder = const ProgressSnapshotBuilder(),
    AchievementsService? achievementsService,
  }) : _achievementsService = achievementsService ?? AchievementsService() {
    start();
  }

  static const int _weightGridStep = 10;
  static const int _weightAxisLabelCount = 5;

  final ProgressService _service;
  final ProgressSnapshotBuilder _builder;
  final AchievementsService _achievementsService;

  StreamSubscription<ProgressRecords>? _subscription;
  ProgressRecords _records = ProgressRecords.empty;
  ProgressSnapshot _snapshot = ProgressSnapshot.empty;
  List<DailyFlowEntry> _flowHistory = const [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void start() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _service.watchRecords().listen(
      _onRecords,
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Could not load your progress. Pull to try again.';
        notifyListeners();
      },
    );
  }

  Future<void> retry() async => start();

  void _onRecords(ProgressRecords records) {
    _records = records;
    final result = _builder.build(records);
    _snapshot = result.snapshot;
    _flowHistory = result.flowHistory;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    if (result.pendingFlowWrites.isNotEmpty) {
      unawaited(_service.saveDailyFlow(result.pendingFlowWrites));
    }
  }

  String get eyebrow => 'Your';

  String get title => 'Progress';

  int get streakDays => _snapshot.streakDays;

  StreakSummary get streakSummary =>
      _achievementsService.streakSummaryOf(_flowHistory);

  bool get isNewUser => !_snapshot.flowScore.hasScores;

  List<ProgressOverviewStat> get overviewStats => [
    ProgressOverviewStat(
      icon: Icons.bolt,
      label: 'AVERAGE FLOW',
      value: '${_snapshot.averageFlow}',
      tone: ProgressTone.primary,
    ),
    ProgressOverviewStat(
      icon: Icons.local_fire_department,
      label: 'CURRENT STREAK',
      value: '${_snapshot.streakDays}d',
      tone: ProgressTone.accent,
    ),
    ProgressOverviewStat(
      icon: Icons.trending_up_rounded,
      label: 'COMPLETED WORKOUTS',
      value: '${_snapshot.completedWorkouts}',
      tone: ProgressTone.neutral,
    ),
  ];

  bool get showChecklist => _checklist.isNotEmpty;

  List<ProgressChecklistItem> get _checklist => _snapshot.checklist;

  List<ProgressChecklistItem> get checklist => List.unmodifiable(_checklist);

  int get completedChecklistCount =>
      _checklist.where((item) => item.isCompleted).length;

  String get checklistProgressLabel =>
      '$completedChecklistCount/${_checklist.length} completed';

  double get checklistProgress =>
      _checklist.isEmpty ? 0 : completedChecklistCount / _checklist.length;

  String get welcomeTitle => 'Welcome to your Progress hub';

  String get welcomeMessage =>
      'This is where all your hard work shows up. Log workouts, track habits '
      'and weigh in — your charts will fill in as you go.';

  String get encouragementTitle => 'Every expert was once a beginner';

  String get encouragementMessage =>
      'Your progress charts will look amazing once you get going. Start small '
      '— one workout, one habit, one meal — and watch this page transform.';

  FlowScoreSummary get flowScore => _snapshot.flowScore;

  String get flowScoreTitle => 'Flow Score';

  String get weeklyRangeLabel => 'This Week';

  String get monthlyRangeLabel => 'Monthly';

  String get flowScoreValueLabel => '${_snapshot.flowScore.score}';

  String get flowScoreDeltaLabel {
    final delta = _snapshot.flowScore.weeklyDelta;
    return '${delta >= 0 ? '+' : ''}$delta this week';
  }

  bool get isFlowScoreImproving => _snapshot.flowScore.weeklyDelta >= 0;

  String get flowScoreEmptyTitle => 'No scores yet';

  String get flowScoreEmptyMessage =>
      'Complete workouts and habits daily to earn your Flow Score. It updates '
      'every day.';

  String get startWorkoutLabel => 'START A WORKOUT';

  WaveInsights? get insights => _snapshot.insights;

  String get insightsTitle => 'WAVE Insights';

  String get improvementLabel => 'Biggest improvement';

  String get weaknessLabel => 'Biggest weakness';

  WeightTracking get weight => _snapshot.weight;

  String get weightTitle => 'Weight Tracking';

  String get addWeightLabel => '+ Add New';

  String get unlogWeightLabel => 'Unlog';

  String get weightUnit => 'kg';

  String get weightValueLabel => weight.currentWeight.toStringAsFixed(2);

  String get weightChangeLabel =>
      '${weight.totalChange.abs().toStringAsFixed(1)} $weightUnit';

  bool get isLosingWeight => weight.totalChange <= 0;

  String get weightTargetLabel => 'Target';

  String get weightTargetValueLabel =>
      '${weight.targetWeight.toStringAsFixed(0)} $weightUnit';

  String get weightPaceLabel {
    final change = weight.weeklyChange;
    if (change == 0) {
      return 'Log another weigh-in this week to see your pace.';
    }
    final pace = change.abs().toStringAsFixed(1);
    final direction = change < 0 ? 'losing' : 'gaining';
    return 'You\'re $direction $pace$weightUnit/week · Keep it steady.';
  }

  String get weightEmptyTitle => 'Start logging your weight';

  String get weightEmptyMessage =>
      'Track your weight over time to see trends and measure progress toward '
      'your goal.';

  String get logWeightLabel => 'LOG FIRST WEIGHT';

  String get weightTargetPillLabel =>
      'Target weight: ${weight.targetWeight.toStringAsFixed(0)} $weightUnit';

  double get weightGoalProgress {
    if (!weight.hasEntries) return 0;
    final total = weight.startWeight - weight.targetWeight;
    if (total == 0) return 1;
    final achieved = weight.startWeight - weight.currentWeight;
    return (achieved / total).clamp(0.0, 1.0);
  }

  String get weightGoalProgressLabel =>
      '${(weightGoalProgress * 100).round()}%';

  List<double> get weightSamples => [
    for (final entry in weight.entries) entry.weight,
  ];

  double get weightAxisMin {
    if (!weight.hasEntries) return 0;
    final lowest = weightSamples.reduce(math.min);
    return ((lowest - _weightGridStep) / _weightGridStep).floor() *
        _weightGridStep.toDouble();
  }

  double get weightAxisMax {
    if (!weight.hasEntries) return 0;
    final highest = weightSamples.reduce(math.max);
    return ((highest + _weightGridStep) / _weightGridStep).ceil() *
        _weightGridStep.toDouble();
  }

  List<String> get weightAxisLabels {
    if (!weight.hasEntries) return const [];
    return [
      for (
        var value = weightAxisMax;
        value >= weightAxisMin;
        value -= _weightGridStep
      )
        value.toStringAsFixed(0),
    ];
  }

  List<String> get weightDateLabels {
    final entries = weight.entries;
    if (entries.isEmpty) return const [];
    final step = math.max(1, (entries.length / _weightAxisLabelCount).round());
    return [
      for (var index = 0; index < entries.length; index += step)
        AppDateUtils.monthDay(entries[index].date),
    ];
  }

  WorkoutVolume get volume => _snapshot.volume;

  String get volumeTitle => 'Workout Volume';

  String get volumeSummaryLabel =>
      '${_snapshot.volume.sessionCount} sessions this week · '
      '${_snapshot.volume.totalSets} sets total';

  String get volumeEmptyTitle => 'No workouts logged yet';

  String get volumeEmptyMessage =>
      'Every session you complete will appear here as a volume bar — building '
      'your weekly picture.';

  String get logWorkoutLabel => 'LOG A WORKOUT';

  List<HabitConsistencyItem> get habits => _snapshot.habits;

  String get habitsTitle => 'Habit Consistency';

  bool get hasHabitData =>
      _snapshot.habits.any((habit) => habit.completedDays > 0);

  String get strongestHabitLabel => 'Strongest';

  String get weakestHabitLabel => 'Weakest';

  String? get strongestHabit => hasHabitData
      ? _snapshot.habits
            .reduce(
              (best, habit) =>
                  habit.completedDays > best.completedDays ? habit : best,
            )
            .label
      : null;

  String? get weakestHabit => hasHabitData
      ? _snapshot.habits
            .reduce(
              (worst, habit) =>
                  habit.completedDays < worst.completedDays ? habit : worst,
            )
            .label
      : null;

  List<PersonalRecord> get records => _snapshot.records;

  String get recordsTitle => 'Personal Records';

  bool get showRecords => _snapshot.records.isNotEmpty;

  String get logWeightTitle => 'Log Weight';

  String get logWeightHint => 'Enter weight in $weightUnit';

  String get saveWeightLabel => 'Save Changes';

  bool canLogWeight(String input) {
    final weight = double.tryParse(input.trim());
    return weight != null && weight > 0;
  }

  Future<String?> logWeight(String input) async {
    final weight = double.tryParse(input.trim());
    if (weight == null || weight <= 0) return 'Enter a valid weight.';
    try {
      await _service.addWeightLog(weight, DateTime.now());
      return null;
    } on ProgressException catch (e) {
      return e.message;
    }
  }

  String get unlogWeightTitle => 'Unlog Weight';

  String get unlogWeightSubtitle =>
      'Remove a weigh-in you logged by mistake. This cannot be undone.';

  String get unlogWeightEmptyMessage => 'You have no weigh-ins to remove yet.';

  String get unlogWeightConfirmTitle => 'Remove this weigh-in?';

  String unlogWeightConfirmMessage(WeightHistoryItem item) =>
      'This deletes your ${item.valueLabel} entry from ${item.dateLabel}. '
      'Your other weigh-ins stay in your history.';

  String get unlogWeightConfirmLabel => 'Remove';

  String get unlogWeightCancelLabel => 'Keep';

  bool get canUnlogWeight => weight.hasEntries;

  List<WeightHistoryItem> get weightHistory {
    final entries = weight.entries;
    return [
      for (var index = entries.length - 1; index >= 0; index -= 1)
        WeightHistoryItem(
          id: entries[index].id,
          valueLabel:
              '${entries[index].weight.toStringAsFixed(1)} $weightUnit',
          dateLabel: AppDateUtils.monthDay(entries[index].date),
          isLatest: index == entries.length - 1,
        ),
    ];
  }

  Future<String?> unlogWeight(String id) async {
    try {
      await _service.deleteWeightLog(id);
      return null;
    } on ProgressException catch (e) {
      return e.message;
    }
  }

  Future<void> toggleChecklistItem(String id) async {
    final item = _checklist.where((item) => item.id == id).firstOrNull;
    if (item == null) return;
    final completed = {..._records.state.completedChecklistIds};
    if (item.isCompleted) {
      completed.remove(id);
    } else {
      completed.add(id);
    }
    await _saveState(
      ProgressState(
        completedChecklistIds: completed,
        isChecklistDismissed: _records.state.isChecklistDismissed,
      ),
    );
  }

  Future<void> dismissChecklist() async {
    if (_records.state.isChecklistDismissed) return;
    await _saveState(
      ProgressState(
        completedChecklistIds: _records.state.completedChecklistIds,
        isChecklistDismissed: true,
      ),
    );
  }

  Future<void> _saveState(ProgressState state) async {
    _records = ProgressRecords(
      weights: _records.weights,
      sessions: _records.sessions,
      habitDays: _records.habitDays,
      storedFlow: _records.storedFlow,
      nutrition: _records.nutrition,
      state: state,
      goals: _records.goals,
    );
    _snapshot = _builder.build(_records).snapshot;
    notifyListeners();
    await _service.saveState(state);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

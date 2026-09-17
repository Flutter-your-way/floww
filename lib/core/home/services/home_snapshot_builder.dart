import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/core/achievements/services/achievements_service.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/services/habit_snapshot_builder.dart';
import 'package:floww/core/habits/view_models/habit_labels.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/core/home/services/home_service.dart';
import 'package:floww/core/home/services/recovery_calculator.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_goal_calculator.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';
import 'package:floww/core/progress/services/flow_score_calculator.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';

class HomeSnapshotBuilder {
  HomeSnapshotBuilder({MuscleRecoveryService? muscleRecoveryService})
    : _muscleRecoveryService =
          muscleRecoveryService ?? MuscleRecoveryService();

  static const int weeklyWindowDays = 7;
  static const int mealsPerDay = FlowScoreCalculator.targetMealsPerDay;
  static const int targetSetsPerSession =
      FlowScoreCalculator.targetSetsPerSession;

  static const int _workoutPoints = 40;
  static const int _habitPoints = 35;
  static const int _nutritionPoints = 25;

  static const int _highIntensitySets = 20;
  static const int _moderateIntensitySets = 12;

  static const int _flowModeFloor = 75;
  static const int _steadyModeFloor = 50;

  static const Map<AppThemeMode, List<String>> _modeTips = {
    AppThemeMode.flow: [
      'Heavy compound lifts',
      'High intensity sets',
      'Full pre-workout nutrition',
      'Chase progressive overload',
    ],
    AppThemeMode.steady: [
      'Moderate working weights',
      'Keep two reps in reserve',
      'Steady pace between sets',
      'Hit your protein target',
    ],
    AppThemeMode.restore: [
      'Light technique work',
      'Mobility and stretching',
      'Extra hydration today',
      'Protect tonight’s sleep',
    ],
  };

  static const FlowScoreCalculator _calculator = FlowScoreCalculator();
  static const RecoveryCalculator _recoveryCalculator = RecoveryCalculator();
  static const NutritionGoalCalculator _goalCalculator =
      NutritionGoalCalculator();

  final MuscleRecoveryService _muscleRecoveryService;

  HomeSnapshot build(HomeRecords records, {required DateTime date}) {
    final today = AppDateUtils.dateOnly(date);
    final account = records.account;
    final goal = _goalOf(records);

    final habitSnapshot = HabitSnapshot.of(records.habits);
    final habits = habitSnapshot.habitsFor(today);
    final nutritionDay = _nutritionDayOf(records, today, goal);

    final completedToday = _completedSessionsOn(records.sessions, today);
    final workoutSets = completedToday.fold<int>(
      0,
      (total, session) => total + session.totalSets,
    );

    final mealCount = records.nutrition.foods
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, today))
        .length;
    final waterMl = records.nutrition.waters
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, today))
        .fold<double>(0, (total, log) => total + log.amountMl);

    final habitCompletion = habitSnapshot.completionFor(today);

    final todayEntry = _calculator.scoreOf(
      FlowScoreInputs(
        date: today,
        workoutSets: workoutSets,
        habitCompletion: habitCompletion,
        mealCount: mealCount,
        waterMl: waterMl,
      ),
    );

    final recovery = _recoveryCalculator.build(
      history: records.healthDays,
      date: today,
      sleepTargetHours: account.sleepTargetHours,
      stepsTarget: account.stepsTarget,
    );

    final muscleSnapshot = _muscleRecoveryService.snapshotOf(
      records.sessions,
      now: date,
    );

    final flowHistory = <DailyFlowEntry>[
      for (final entry in records.flowHistory)
        if (!AppDateUtils.isSameDay(entry.date, today)) entry,
      todayEntry,
    ];

    return HomeSnapshot(
      userName: (account.name ?? '').trim(),
      streakCount: AchievementsService.currentStreakOf(
        AchievementsService.flowByDay(flowHistory),
        today,
      ),
      flowScorePercent: todayEntry.score,
      flowScoreBreakdown: FlowScoreBreakdown(
        weeklyAveragePercent: _weeklyAverageOf(flowHistory, today),
        components: _componentsOf(
          entry: todayEntry,
          workoutSets: workoutSets,
          habits: habits,
          mealCount: mealCount,
          waterMl: waterMl,
        ),
      ),
      flowScoreBoosts: _boostsOf(todayEntry),
      recovery: recovery,
      flowMode: _flowModeOf(
        recovery: recovery,
        records: records,
        today: today,
      ),
      habits: [
        for (final habit in habits)
          HabitItem(
            id: habit.id,
            title: habit.title,
            valueLabel: HabitLabels.progress(habit),
            completed: habit.isCompleted,
          ),
      ],
      workout: _workoutOf(records: records, recovery: recovery, today: today),
      nutrition: NutritionSummary(
        totalCalories: nutritionDay.calories.round(),
        calorieGoal: goal.calories,
        proteinG: nutritionDay.proteinG.round(),
        carbsG: nutritionDay.carbsG.round(),
        fatsG: nutritionDay.fatG.round(),
      ),
      todayProgress: _progressOf(
        habits: habits,
        hasPlan: records.plan != null,
        completedWorkouts: completedToday.length,
        mealCount: mealCount,
        recovery: recovery,
      ),
      muscleRecovery: _muscleDataOf(muscleSnapshot, today),
      waveInsight: _insightOf(
        recovery: recovery,
        records: records,
        today: today,
        workoutSets: workoutSets,
        habits: habits,
      ),
      todayFlowEntry: todayEntry,
    );
  }

  NutritionGoal _goalOf(HomeRecords records) =>
      _goalCalculator.build(records.account);

  NutritionDay _nutritionDayOf(
    HomeRecords records,
    DateTime today,
    NutritionGoal goal,
  ) => NutritionDay(
    date: today,
    goal: goal,
    foodLogs: records.nutrition.foods
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, today))
        .toList(),
    waterLogs: records.nutrition.waters
        .where((log) => AppDateUtils.isSameDay(log.loggedAt, today))
        .toList(),
  );

  static List<WorkoutSessionEntity> _completedSessionsOn(
    List<WorkoutSessionEntity> sessions,
    DateTime day,
  ) => [
    for (final session in sessions)
      if (session.status == WorkoutSessionStatus.completed &&
          AppDateUtils.isSameDay(session.date, day))
        session,
  ];

  int _weeklyAverageOf(List<DailyFlowEntry> history, DateTime today) {
    final from = AppDateUtils.addDays(today, -(weeklyWindowDays - 1));
    var total = 0;
    var days = 0;
    for (final entry in history) {
      final day = AppDateUtils.dateOnly(entry.date);
      if (day.isBefore(from) || day.isAfter(today)) continue;
      if (!entry.hasActivity) continue;
      total += entry.score;
      days++;
    }
    return days == 0 ? 0 : (total / days).round();
  }

  List<FlowScoreComponent> _componentsOf({
    required DailyFlowEntry entry,
    required int workoutSets,
    required List<Habit> habits,
    required int mealCount,
    required double waterMl,
  }) {
    final habitsDone = habits.where((habit) => habit.isCompleted).length;
    final waterLiters = NutritionLabels.liters(waterMl);

    return [
      _componentOf(
        emoji: '💪',
        title: 'Workout',
        detail: '$workoutSets / $targetSetsPerSession sets logged',
        score: entry.workoutScore,
        maxPoints: _workoutPoints,
        hint: "Complete today's workout",
      ),
      _componentOf(
        emoji: '✅',
        title: 'Habit Completion',
        detail: '$habitsDone/${habits.length} habits done today',
        score: entry.habitScore,
        maxPoints: _habitPoints,
        hint: "Complete today's habits",
      ),
      _componentOf(
        emoji: '🥗',
        title: 'Nutrition',
        detail: '$mealCount / $mealsPerDay meals · ${waterLiters}L water',
        score: entry.nutritionScore,
        maxPoints: _nutritionPoints,
        hint: 'Log a meal and hit your water goal',
      ),
    ];
  }

  FlowScoreComponent _componentOf({
    required String emoji,
    required String title,
    required String detail,
    required int score,
    required int maxPoints,
    required String hint,
  }) {
    final points = (maxPoints * score / 100).round();
    return FlowScoreComponent(
      emoji: emoji,
      title: title,
      detail: detail,
      points: points,
      maxPoints: maxPoints,
      hintPoints: maxPoints - points,
      hint: hint,
    );
  }

  List<FlowScoreBoost> _boostsOf(DailyFlowEntry entry) => [
    FlowScoreBoost(
      label: 'Workout',
      points: _workoutPoints,
      completed: entry.workoutScore >= 100,
    ),
    FlowScoreBoost(
      label: 'Habits',
      points: _habitPoints,
      completed: entry.habitScore >= 100,
    ),
    FlowScoreBoost(
      label: 'Nutrition',
      points: _nutritionPoints,
      completed: entry.nutritionScore >= 100,
    ),
  ];

  FlowModeDetail? _flowModeOf({
    required RecoveryDetail recovery,
    required HomeRecords records,
    required DateTime today,
  }) {
    if (!recovery.hasData) return null;

    final mode = modeOf(recovery.percent);
    final reasons = <String>['Recovery is ${recovery.levelLabel}'];

    for (final metric in recovery.metrics) {
      if (metric.label == 'Sleep') {
        reasons.add('Slept ${metric.valueLabel} last night');
      }
    }

    final lastWorkout = _lastCompletedSession(records.sessions);
    if (lastWorkout != null) {
      reasons.add(
        'Last workout ${AppDateUtils.relativeDay(lastWorkout.completedAt, now: today).toLowerCase()}',
      );
    }

    return FlowModeDetail(
      mode: mode,
      statusLabel: 'Active today · Set by WAVE AI',
      reasons: reasons,
      tips: _modeTips[mode] ?? const [],
    );
  }

  static AppThemeMode modeOf(int recoveryPercent) {
    if (recoveryPercent >= _flowModeFloor) return AppThemeMode.flow;
    if (recoveryPercent >= _steadyModeFloor) return AppThemeMode.steady;
    return AppThemeMode.restore;
  }

  WorkoutRecommendation? _workoutOf({
    required HomeRecords records,
    required RecoveryDetail recovery,
    required DateTime today,
  }) {
    final plan = records.plan;
    if (plan == null) return null;

    final reasons = <String>[];
    if (recovery.hasData) {
      reasons.add('Recovery is ${recovery.levelLabel}');
    }

    final lastWorkout = _lastCompletedSession(records.sessions);
    if (lastWorkout != null) {
      final hours = today.difference(
        AppDateUtils.dateOnly(lastWorkout.completedAt),
      ).inDays;
      reasons.add(
        hours == 0 ? 'Trained earlier today' : 'Last workout ${hours}d ago',
      );
    } else {
      reasons.add('Your first logged session');
    }

    if (plan.programLabel.isNotEmpty) reasons.add(plan.programLabel);

    return WorkoutRecommendation(
      title: plan.name,
      durationLabel: '${plan.durationMinutes}m',
      intensityLabel: _intensityOf(plan.totalSets),
      reasons: reasons,
    );
  }

  static String _intensityOf(int totalSets) {
    if (totalSets >= _highIntensitySets) return 'High Intensity';
    if (totalSets >= _moderateIntensitySets) return 'Moderate Intensity';
    return 'Light Intensity';
  }

  TodayProgress _progressOf({
    required List<Habit> habits,
    required bool hasPlan,
    required int completedWorkouts,
    required int mealCount,
    required RecoveryDetail recovery,
  }) {
    final items = <ProgressItem>[];
    var completed = 0;
    var total = 0;

    if (habits.isNotEmpty) {
      final done = habits.where((habit) => habit.isCompleted).length;
      completed += done;
      total += habits.length;
      items.add(
        ProgressItem(
          label: 'Habits',
          fraction: '$done/${habits.length}',
          isComplete: done == habits.length,
        ),
      );
    }

    if (hasPlan || completedWorkouts > 0) {
      final planned = hasPlan ? 1 : completedWorkouts;
      final done = completedWorkouts.clamp(0, planned);
      completed += done;
      total += planned;
      items.add(
        ProgressItem(
          label: 'Workout',
          fraction: '$done/$planned',
          isComplete: done >= planned,
        ),
      );
    }

    final meals = mealCount.clamp(0, mealsPerDay);
    completed += meals;
    total += mealsPerDay;
    items.add(
      ProgressItem(
        label: 'Nutrition',
        fraction: '$meals/$mealsPerDay',
        isComplete: meals >= mealsPerDay,
      ),
    );

    for (final metric in recovery.metrics) {
      if (metric.label != 'Sleep') continue;
      final done = metric.percent >= 100 ? 1 : 0;
      completed += done;
      total += 1;
      items.add(
        ProgressItem(
          label: 'Sleep Goal',
          fraction: '$done/1',
          isComplete: done == 1,
        ),
      );
    }

    return TodayProgress(
      completedCount: completed,
      totalCount: total,
      items: items,
    );
  }

  MuscleRecoveryData _muscleDataOf(
    MuscleRecoverySnapshot snapshot,
    DateTime today,
  ) {
    final lastWorkoutAt = snapshot.lastWorkoutAt;
    return MuscleRecoveryData(
      daysSinceLastWorkout: lastWorkoutAt == null
          ? 0
          : AppDateUtils.daysBetween(
              AppDateUtils.dateOnly(lastWorkoutAt),
              today,
            ),
      inRecoveryCount: _countOf(snapshot, MuscleRecoveryStatus.recovering),
      readyMusclesCount: _countOf(snapshot, MuscleRecoveryStatus.ready),
      fatiguedMusclesCount: _countOf(snapshot, MuscleRecoveryStatus.fatigued),
      statuses: {
        for (final item in snapshot.items) item.group: item.status,
      },
    );
  }

  static int _countOf(
    MuscleRecoverySnapshot snapshot,
    MuscleRecoveryStatus status,
  ) => snapshot.items.where((item) => item.status == status).length;

  String? _insightOf({
    required RecoveryDetail recovery,
    required HomeRecords records,
    required DateTime today,
    required int workoutSets,
    required List<Habit> habits,
  }) {
    final plan = records.plan;

    if (recovery.hasData && recovery.percent >= _flowModeFloor) {
      if (workoutSets == 0 && plan != null) {
        return 'Recovery is ${recovery.levelLabel.toLowerCase()} — a prime '
            'window to push on ${plan.name}.';
      }
      return 'Recovery is ${recovery.levelLabel.toLowerCase()}. Keep the '
          'momentum and stay on top of your habits today.';
    }

    if (recovery.hasData && recovery.percent < _steadyModeFloor) {
      return 'Recovery is ${recovery.levelLabel.toLowerCase()} — keep today '
          'light and protect tonight’s sleep.';
    }

    if (habits.isEmpty && plan == null) return null;

    if (workoutSets == 0 && plan != null) {
      return '${plan.name} is queued for today. Logging it is worth up to '
          '$_workoutPoints Flow points.';
    }

    final pending = habits.where((habit) => !habit.isCompleted).length;
    if (pending > 0) {
      return '$pending habit${pending == 1 ? '' : 's'} left today — worth up '
          'to $_habitPoints Flow points.';
    }

    return null;
  }

  static WorkoutSessionEntity? _lastCompletedSession(
    List<WorkoutSessionEntity> sessions,
  ) {
    WorkoutSessionEntity? latest;
    for (final session in sessions) {
      if (session.status != WorkoutSessionStatus.completed) continue;
      if (latest == null || session.completedAt.isAfter(latest.completedAt)) {
        latest = session;
      }
    }
    return latest;
  }
}

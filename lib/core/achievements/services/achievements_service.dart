import 'package:floww/config/entities/daily_flow_entity.dart';
import 'package:floww/config/entities/habit_day_log_entity.dart';
import 'package:floww/config/entities/workout_session_entity.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/streams/combine_latest.dart';
import 'package:floww/core/achievements/models/achievement.dart';
import 'package:floww/core/achievements/models/streak_day.dart';
import 'package:floww/core/achievements/models/streak_day_status.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/services/achievements_data.dart';
import 'package:floww/core/auth/services/auth_service.dart';
import 'package:floww/core/habits/services/habit_log_service.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/progress/services/progress_service.dart';
import 'package:floww/core/recovery/services/muscle_recovery_service.dart';
import 'package:floww/core/workout/services/workout_session_service.dart';

class AchievementsRecords {
  const AchievementsRecords({
    required this.flowHistory,
    required this.habitDays,
    required this.sessions,
    required this.nutrition,
  });

  static const empty = AchievementsRecords(
    flowHistory: [],
    habitDays: [],
    sessions: [],
    nutrition: NutritionLogs.empty,
  );

  final List<DailyFlowEntry> flowHistory;
  final List<HabitDayLog> habitDays;
  final List<WorkoutSessionEntity> sessions;
  final NutritionLogs nutrition;
}

class AchievementsService {
  AchievementsService({
    ProgressService? progressService,
    HabitLogService? habitLogService,
    WorkoutSessionService? sessionService,
    NutritionLogService? nutritionLogService,
    MuscleRecoveryService? recoveryService,
    AuthService? authService,
  }) : _injectedAuthService = authService,
       _injectedProgressService = progressService,
       _injectedHabitLogService = habitLogService,
       _injectedSessionService = sessionService,
       _injectedNutritionLogService = nutritionLogService,
       _injectedRecoveryService = recoveryService;

  static const int historyDays = 365;
  static const int completedFloor = 70;
  static const int weeklyVolumeTargetKg = 10000;
  static const double waterGoalMl = 2500;
  static const int hydrationTargetDays = 7;
  static const int habitStackSize = 5;
  static const int routineMasterLogs = 100;
  static const int dailyDriverDays = 7;
  static const int peakFlowScore = 100;

  final ProgressService? _injectedProgressService;
  final HabitLogService? _injectedHabitLogService;
  final WorkoutSessionService? _injectedSessionService;
  final NutritionLogService? _injectedNutritionLogService;
  final MuscleRecoveryService? _injectedRecoveryService;
  final AuthService? _injectedAuthService;

  ProgressService? _progressServiceCache;
  HabitLogService? _habitLogServiceCache;
  WorkoutSessionService? _sessionServiceCache;
  NutritionLogService? _nutritionLogServiceCache;
  MuscleRecoveryService? _recoveryServiceCache;
  AuthService? _authServiceCache;

  ProgressService get _progressService =>
      _injectedProgressService ??
      (_progressServiceCache ??= ProgressService());

  HabitLogService get _habitLogService =>
      _injectedHabitLogService ??
      (_habitLogServiceCache ??= HabitLogService());

  WorkoutSessionService get _sessionService =>
      _injectedSessionService ??
      (_sessionServiceCache ??= WorkoutSessionService());

  NutritionLogService get _nutritionLogService =>
      _injectedNutritionLogService ??
      (_nutritionLogServiceCache ??= NutritionLogService());

  MuscleRecoveryService get _recoveryService =>
      _injectedRecoveryService ??
      (_recoveryServiceCache ??= MuscleRecoveryService());

  AuthService get _authService =>
      _injectedAuthService ?? (_authServiceCache ??= AuthService());

  DateTime? get _joinedAt {
    final createdAt = _authService.accountCreatedAt;
    return createdAt == null ? null : AppDateUtils.dateOnly(createdAt);
  }

  Stream<AchievementsRecords> watchRecords() {
    final from = AppDateUtils.addDays(
      AppDateUtils.dateOnly(DateTime.now()),
      -historyDays,
    );

    return combineLatest([
      _progressService.watchDailyFlow(from),
      _habitLogService.watchDays(from),
      _sessionService.watchRecentSessions(),
      _nutritionLogService.watchLogs(
        from,
        AppDateUtils.addDays(AppDateUtils.dateOnly(DateTime.now()), 1),
      ),
    ]).map(
      (values) => AchievementsRecords(
        flowHistory: values[0]! as List<DailyFlowEntry>,
        habitDays: values[1]! as List<HabitDayLog>,
        sessions: values[2]! as List<WorkoutSessionEntity>,
        nutrition: values[3]! as NutritionLogs,
      ),
    );
  }

  List<Achievement> achievementsOf(AchievementsRecords records) {
    final flow = flowByDay(records.flowHistory);
    final today = AppDateUtils.dateOnly(DateTime.now());
    final longestStreak = longestStreakOf(flow);
    final completed = records.sessions
        .where((session) => session.status == WorkoutSessionStatus.completed)
        .toList();

    final unlocks = <String, bool>{
      'first_flame': longestStreak >= 3,
      'week_warrior': longestStreak >= 7,
      'fortnight_force': longestStreak >= 14,
      'monthly_master': longestStreak >= 30,
      'first_sweat': completed.isNotEmpty,
      'consistent': completed.length >= 10,
      'iron_will': completed.length >= 50,
      'century_lifter': completed.length >= 100,
      'habit_starter': records.habitDays.any((day) => day.entries.isNotEmpty),
      'daily_driver': _habitStreakOf(records.habitDays, today) >=
          dailyDriverDays,
      'habit_stack': records.habitDays.any(
        (day) => day.entries.length >= habitStackSize,
      ),
      'routine_master': _completedHabitLogsOf(records.habitDays) >=
          routineMasterLogs,
      'personal_best': completed.any(
        (session) => session.personalRecords.isNotEmpty,
      ),
      'volume_up': _bestWeeklyVolumeOf(completed) >= weeklyVolumeTargetKg,
      'peak_flow': flow.values.any((entry) => entry.score >= peakFlowScore),
      'recovery_pro': _isFullyRecovered(completed),
      'clean_plate': records.nutrition.foods.isNotEmpty,
      'hydrated': _hydratedDaysOf(records.nutrition) >= hydrationTargetDays,
    };

    return [
      for (final achievement in AchievementsData.achievements)
        achievement.unlocked(unlocks[achievement.id] ?? false),
    ];
  }

  StreakSummary streakSummaryOf(
    List<DailyFlowEntry> flowHistory, {
    DateTime? date,
    DateTime? joinedAt,
  }) {
    final today = AppDateUtils.dateOnly(date ?? DateTime.now());
    final flow = flowByDay(flowHistory);
    final weekStart = AppDateUtils.startOfWeek(today);
    final joined = joinedAt == null
        ? _joinedAt ?? _firstTrackedDayOf(flowHistory) ?? today
        : AppDateUtils.dateOnly(joinedAt);
    final monthStart = DateTime(today.year, today.month);
    final trackedStart = joined.isAfter(monthStart) ? joined : monthStart;

    var monthCompleted = 0;
    for (var day = trackedStart.day; day <= today.day; day++) {
      final entry = flow[AppDateUtils.dateKey(
        DateTime(today.year, today.month, day),
      )];
      if (entry?.hasActivity ?? false) monthCompleted++;
    }

    return StreakSummary(
      currentDays: currentStreakOf(flow, today),
      bestDays: longestStreakOf(flow),
      monthCompletedDays: monthCompleted,
      monthTotalDays: today.day - trackedStart.day + 1,
      days: [
        for (var index = 0; index < DateTime.daysPerWeek; index++)
          _streakDayOf(
            flow,
            AppDateUtils.addDays(weekStart, index),
            today,
            joined,
          ),
      ],
      milestones: AchievementsData.milestones,
    );
  }

  static DateTime? _firstTrackedDayOf(List<DailyFlowEntry> flowHistory) {
    DateTime? earliest;
    for (final entry in flowHistory) {
      final day = AppDateUtils.dateOnly(entry.date);
      if (earliest == null || day.isBefore(earliest)) earliest = day;
    }
    return earliest;
  }

  static Map<String, DailyFlowEntry> flowByDay(List<DailyFlowEntry> history) => {
    for (final entry in history) AppDateUtils.dateKey(entry.date): entry,
  };

  static int currentStreakOf(Map<String, DailyFlowEntry> flow, DateTime today) {
    var cursor = today;
    if (!(flow[AppDateUtils.dateKey(cursor)]?.hasActivity ?? false)) {
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    var streak = 0;
    while (flow[AppDateUtils.dateKey(cursor)]?.hasActivity ?? false) {
      streak++;
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  static int longestStreakOf(Map<String, DailyFlowEntry> flow) {
    final days =
        flow.values.where((entry) => entry.hasActivity).map((entry) => entry.date).toList()
          ..sort();
    var longest = 0;
    var running = 0;
    DateTime? previous;
    for (final day in days) {
      running = previous != null && AppDateUtils.daysBetween(previous, day) == 1
          ? running + 1
          : 1;
      if (running > longest) longest = running;
      previous = day;
    }
    return longest;
  }

  StreakDay _streakDayOf(
    Map<String, DailyFlowEntry> flow,
    DateTime date,
    DateTime today,
    DateTime joinedAt,
  ) {
    final label = AppDateUtils.shortWeekday(date).substring(0, 1);
    if (date.isAfter(today) || date.isBefore(joinedAt)) {
      return StreakDay(label: label, status: StreakDayStatus.upcoming);
    }
    final score = flow[AppDateUtils.dateKey(date)]?.score ?? 0;
    if (score >= completedFloor) {
      return StreakDay(label: label, status: StreakDayStatus.completed);
    }
    if (score > 0) {
      return StreakDay(label: label, status: StreakDayStatus.partial);
    }
    return StreakDay(label: label, status: StreakDayStatus.missed);
  }

  int _habitStreakOf(List<HabitDayLog> habitDays, DateTime today) {
    final byDay = {
      for (final day in habitDays) AppDateUtils.dateKey(day.date): day,
    };
    var cursor = today;
    if ((byDay[AppDateUtils.dateKey(cursor)]?.entries.isEmpty ?? true)) {
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    var streak = 0;
    while (byDay[AppDateUtils.dateKey(cursor)]?.entries.isNotEmpty ?? false) {
      streak++;
      cursor = AppDateUtils.addDays(cursor, -1);
    }
    return streak;
  }

  int _completedHabitLogsOf(List<HabitDayLog> habitDays) {
    var total = 0;
    for (final day in habitDays) {
      total += day.entries.where((entry) => entry.isCompleted).length;
    }
    return total;
  }

  double _bestWeeklyVolumeOf(List<WorkoutSessionEntity> sessions) {
    if (sessions.isEmpty) return 0;
    final byWeek = <String, double>{};
    for (final session in sessions) {
      final key = AppDateUtils.dateKey(
        AppDateUtils.startOfWeek(session.completedAt),
      );
      byWeek[key] = (byWeek[key] ?? 0) + session.volumeKg;
    }
    return byWeek.values.reduce((a, b) => a > b ? a : b);
  }

  bool _isFullyRecovered(List<WorkoutSessionEntity> sessions) {
    if (sessions.isEmpty) return false;
    final snapshot = _recoveryService.snapshotOf(sessions);
    return snapshot.items.every(
      (item) => item.percent >= MuscleRecoveryService.fullRecoveryPercent,
    );
  }

  int _hydratedDaysOf(NutritionLogs nutrition) {
    final byDay = <String, double>{};
    for (final log in nutrition.waters) {
      final key = AppDateUtils.dateKey(log.loggedAt);
      byDay[key] = (byDay[key] ?? 0) + log.amountMl;
    }
    return byDay.values.where((amount) => amount >= waterGoalMl).length;
  }
}

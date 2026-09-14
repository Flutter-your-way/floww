import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floww/config/theme/app_mode.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/utils/dates/day_rollover_timer.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';
import 'package:floww/core/nutrition/models/nutrition_goal.dart';
import 'package:floww/core/nutrition/services/nutrition_log_service.dart';
import 'package:floww/core/nutrition/view_models/nutrition_labels.dart';

class FlowScoreBoost {
  const FlowScoreBoost({
    required this.label,
    required this.points,
    required this.completed,
  });

  final String label;
  final int points;
  final bool completed;
}

class HabitItem {
  const HabitItem({
    required this.title,
    required this.valueLabel,
    required this.completed,
  });

  final String title;
  final String valueLabel;
  final bool completed;
}

class WorkoutRecommendation {
  const WorkoutRecommendation({
    required this.title,
    required this.durationLabel,
    required this.intensityLabel,
    required this.reasons,
  });

  final String title;
  final String durationLabel;
  final String intensityLabel;
  final List<String> reasons;
}

class NutritionSummary {
  const NutritionSummary({
    required this.totalCalories,
    required this.calorieGoal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  final int totalCalories;
  final int calorieGoal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
}

class ProgressItem {
  const ProgressItem({
    required this.label,
    required this.fraction,
    required this.isComplete,
  });

  final String label;
  final String fraction;
  final bool isComplete;
}

class TodayProgress {
  const TodayProgress({
    required this.completedCount,
    required this.totalCount,
    required this.items,
  });

  final int completedCount;
  final int totalCount;
  final List<ProgressItem> items;

  int get percent =>
      totalCount == 0 ? 0 : ((completedCount / totalCount) * 100).round();
}

class MuscleRecoveryData {
  const MuscleRecoveryData({
    required this.daysSinceLastWorkout,
    required this.inRecoveryCount,
    required this.readyMusclesCount,
    required this.fatiguedMusclesCount,
  });

  final int daysSinceLastWorkout;
  final int inRecoveryCount;
  final int readyMusclesCount;
  final int fatiguedMusclesCount;
}

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._logService) {
    _greeting = _greetingForHour(DateTime.now().hour);
    _watchToday();
    _dayRollover = DayRolloverTimer(_onNewDay);
  }

  static const double _nutritionGoalRatio = 0.9;

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  final NutritionLogService _logService;
  final NutritionGoal _goal = NutritionGoal.defaults;
  late NutritionDay _today;
  StreamSubscription<NutritionLogs>? _todaySubscription;
  late final DayRolloverTimer _dayRollover;
  bool _disposed = false;

  late String _greeting;
  String get greeting => _greeting;

  final String userName = 'Sarah Mitchell';
  final int streakCount = 29;
  final String? avatarUrl = null;

  final int flowScorePercent = 74;
  final String? recoveryLevel = 'High';
  final AppThemeMode? todayMode = AppThemeMode.flow;

  final List<FlowScoreBoost> flowScoreBoosts = const [
    FlowScoreBoost(label: 'Workout', points: 8, completed: true),
    FlowScoreBoost(label: 'Protein Goal', points: 3, completed: false),
    FlowScoreBoost(label: 'Water Goal', points: 2, completed: false),
    FlowScoreBoost(label: 'Sleep Goal', points: 5, completed: false),
  ];

  List<HabitItem> get habits => [
    HabitItem(
      title: 'Water Intake',
      valueLabel:
          '${NutritionLabels.liters(_today.waterMl)}L / '
          '${NutritionLabels.liters(_goal.waterMl.toDouble())}L Target',
      completed: _today.waterMl >= _goal.waterMl,
    ),
    const HabitItem(
      title: 'Sleep Quality',
      valueLabel: '8h 12m logged',
      completed: false,
    ),
    const HabitItem(
      title: 'Daily Steps',
      valueLabel: '8,432 / 10,000',
      completed: false,
    ),
  ];

  final WorkoutRecommendation? workout = const WorkoutRecommendation(
    title: 'Push Day: Chest & Triceps',
    durationLabel: '60m',
    intensityLabel: 'High Intensity',
    reasons: ['Recovery is High', 'Last workout 48h ago', 'FLOW mode active'],
  );

  NutritionSummary get nutrition => NutritionSummary(
    totalCalories: _today.calories.round(),
    calorieGoal: _goal.calories,
    proteinG: _today.proteinG.round(),
    carbsG: _today.carbsG.round(),
    fatsG: _today.fatG.round(),
  );

  bool get _nutritionGoalMet =>
      _today.calories >= _goal.calories * _nutritionGoalRatio;

  TodayProgress get todayProgress {
    final habitItems = habits;
    final habitsDone = habitItems.where((habit) => habit.completed).length;
    final nutritionDone = _nutritionGoalMet ? 1 : 0;
    return TodayProgress(
      completedCount: habitsDone + nutritionDone,
      totalCount: habitItems.length + 3,
      items: [
        ProgressItem(
          label: 'Habits',
          fraction: '$habitsDone/${habitItems.length}',
          isComplete: habitsDone == habitItems.length,
        ),
        const ProgressItem(label: 'Workout', fraction: '0/1', isComplete: false),
        ProgressItem(
          label: 'Nutrition',
          fraction: '$nutritionDone/1',
          isComplete: _nutritionGoalMet,
        ),
        const ProgressItem(
          label: 'Sleep Goal',
          fraction: '0/1',
          isComplete: false,
        ),
      ],
    );
  }

  final String? waveInsight =
      'Recovery is high. Neural fatigue minimal — prime window for a push session PB.';

  final MuscleRecoveryData muscleRecovery = const MuscleRecoveryData(
    daysSinceLastWorkout: 0,
    inRecoveryCount: 3,
    readyMusclesCount: 7,
    fatiguedMusclesCount: 2,
  );

  void _onNewDay() {
    _greeting = _greetingForHour(DateTime.now().hour);
    _watchToday();
  }

  void _watchToday() {
    _todaySubscription?.cancel();
    final date = AppDateUtils.dateOnly(DateTime.now());
    _today = NutritionDay(date: date, goal: _goal);
    notifyListeners();
    _todaySubscription = _logService
        .watchLogs(date, AppDateUtils.addDays(date, 1))
        .listen(
          (logs) {
            _today = NutritionDay(
              date: date,
              goal: _goal,
              foodLogs: logs.foods,
              waterLogs: logs.waters,
            );
            notifyListeners();
          },
          onError: (Object error) =>
              debugPrint('home nutrition watch failed: $error'),
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
    _todaySubscription?.cancel();
    super.dispose();
  }
}

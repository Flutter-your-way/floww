enum HabitDayStatus { completed, partial, missed, rest, upcoming }

class HabitDay {
  const HabitDay({
    required this.date,
    required this.completion,
    required this.status,
  });

  final DateTime date;
  final double completion;
  final HabitDayStatus status;
}

class HabitQuitProgress {
  const HabitQuitProgress({
    required this.dayCount,
    required this.targetDays,
    required this.slipDates,
  });

  final int dayCount;
  final int targetDays;
  final List<DateTime> slipDates;

  int get slipCount => slipDates.length;

  DateTime? get lastSlip => slipDates.isEmpty ? null : slipDates.last;

  bool get isAchieved => dayCount >= targetDays;

  double get progress =>
      targetDays <= 0 ? 0 : (dayCount / targetDays).clamp(0.0, 1.0);
}

class HabitStreak {
  const HabitStreak({required this.title, required this.days});

  final String title;
  final int days;
}

class HabitStats {
  const HabitStats({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weeklyCompletionPercent,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final int weeklyCompletionPercent;
}

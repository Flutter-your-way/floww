enum HabitDayStatus { completed, partial, missed, upcoming }

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

class HabitStreak {
  const HabitStreak({required this.title, required this.days});

  final String title;
  final int days;
}

class HabitStats {
  const HabitStats({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weeklyAverageMinutes,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final int weeklyAverageMinutes;
}

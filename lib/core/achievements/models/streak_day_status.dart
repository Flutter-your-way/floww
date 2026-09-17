enum StreakDayStatus {
  completed,
  partial,
  missed,
  upcoming;

  String get label => switch (this) {
    StreakDayStatus.completed => 'Completed',
    StreakDayStatus.partial => 'Partial',
    StreakDayStatus.missed => 'Missed',
    StreakDayStatus.upcoming => 'Upcoming',
  };
}

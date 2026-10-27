class HabitReminder {
  const HabitReminder({
    required this.habitId,
    required this.title,
    required this.body,
    required this.at,
  });

  final String habitId;
  final String title;
  final String body;
  final DateTime at;
}

class WorkoutSuggestion {
  const WorkoutSuggestion({
    required this.title,
    required this.durationMinutes,
    required this.intensity,
    required this.reasons,
  });

  final String title;
  final int durationMinutes;
  final String intensity;
  final List<String> reasons;
}

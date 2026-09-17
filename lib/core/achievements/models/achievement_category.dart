enum AchievementCategory {
  streaks,
  fitness,
  habits,
  performance,
  nutrition;

  String get label => switch (this) {
    AchievementCategory.streaks => 'Streaks',
    AchievementCategory.fitness => 'Fitness',
    AchievementCategory.habits => 'Habits',
    AchievementCategory.performance => 'Performance',
    AchievementCategory.nutrition => 'Nutrition',
  };
}

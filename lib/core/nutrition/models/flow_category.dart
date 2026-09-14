enum FlowCategory {
  calories('Calories', 5, 'Hitting your calorie goal'),
  protein('Protein', 5, 'Hitting your protein goal'),
  carbs('Carbs', 3, 'Staying close to your carb target'),
  fats('Fats', 3, 'Staying close to your fat target'),
  water('Water', 3, 'Reaching your water goal'),
  fiber('Fiber', 2, 'Reaching your fiber goal'),
  mealTiming('Meal Timing', 2, 'Logging all four meals'),
  sugar('Sugar', 1, 'Staying under your sugar limit'),
  sodium('Sodium', 1, 'Staying under your sodium limit');

  const FlowCategory(this.label, this.maxPerDay, this.habit);

  final String label;
  final int maxPerDay;
  final String habit;

  static int get dailyMax =>
      values.fold(0, (total, category) => total + category.maxPerDay);
}

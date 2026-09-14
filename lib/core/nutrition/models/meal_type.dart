enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snacks('Snacks');

  const MealType(this.label);

  final String label;

  static MealType forTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 4 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 22) return MealType.dinner;
    return MealType.snacks;
  }
}

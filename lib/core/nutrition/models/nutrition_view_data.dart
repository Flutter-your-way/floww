import 'package:floww/core/nutrition/models/food_log.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/meal_type.dart';
import 'package:floww/core/nutrition/models/nutrition_day.dart';

enum MicronutrientKind { water, fiber, sugar, sodium }

class MacroShare {
  const MacroShare({
    required this.macro,
    required this.share,
    required this.shareLabel,
    this.amountLabel = '',
  });

  final MacroNutrient macro;
  final double share;
  final String shareLabel;
  final String amountLabel;
}

class MacroProgressItem {
  const MacroProgressItem({
    required this.macro,
    required this.amountLabel,
    required this.goalLabel,
    required this.percentLabel,
    required this.progress,
  });

  final MacroNutrient macro;
  final String amountLabel;
  final String goalLabel;
  final String percentLabel;
  final double progress;
}

class MicronutrientTileItem {
  const MicronutrientTileItem({
    required this.kind,
    required this.label,
    required this.valueLabel,
    required this.goalLabel,
    required this.percentLabel,
    required this.progress,
    this.isOverLimit = false,
  });

  final MicronutrientKind kind;
  final String label;
  final String valueLabel;
  final String goalLabel;
  final String percentLabel;
  final double progress;
  final bool isOverLimit;
}

class MealBreakdownItem {
  const MealBreakdownItem({
    required this.meal,
    required this.subtitle,
    required this.caloriesLabel,
    required this.shareLabel,
    required this.share,
    required this.hasItems,
  });

  final MealType meal;
  final String subtitle;
  final String caloriesLabel;
  final String shareLabel;
  final double share;
  final bool hasItems;
}

class FlowPointRow {
  const FlowPointRow({
    required this.label,
    required this.detail,
    required this.pointsLabel,
    required this.progress,
  });

  final String label;
  final String detail;
  final String pointsLabel;
  final double progress;
}

class RecentFoodItem {
  const RecentFoodItem({
    required this.log,
    required this.name,
    required this.caloriesLabel,
  });

  final FoodLog log;
  final String name;
  final String caloriesLabel;

  MealType get meal => log.mealType;
}

class ChartBar {
  const ChartBar({
    required this.label,
    required this.value,
    this.valueLabel,
    this.isHighlighted = false,
  });

  final String label;
  final double value;
  final String? valueLabel;
  final bool isHighlighted;
}

class DayStatusItem {
  const DayStatusItem({required this.label, required this.status});

  final String label;
  final DayLogStatus status;
}

class FoodItemData {
  const FoodItemData({
    required this.id,
    required this.name,
    required this.servingLabel,
    required this.caloriesLabel,
    required this.proteinLabel,
    required this.carbsLabel,
    required this.fatLabel,
    required this.isScanned,
  });

  final String id;
  final String name;
  final String servingLabel;
  final String caloriesLabel;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;
  final bool isScanned;
}

class MealTimelineEntry {
  const MealTimelineEntry({
    required this.meal,
    required this.caloriesLabel,
    required this.isSelected,
  });

  final MealType meal;
  final String caloriesLabel;
  final bool isSelected;
}

class WaterQuickAmount {
  const WaterQuickAmount({required this.label, required this.amountMl});

  final String label;
  final int amountMl;

  String get amountLabel => '$amountMl ml';
}

class WaterLogItem {
  const WaterLogItem({
    required this.id,
    required this.amountLabel,
    required this.timeLabel,
  });

  final String id;
  final String amountLabel;
  final String timeLabel;
}

class DietPlanMealItem {
  const DietPlanMealItem({
    required this.meal,
    required this.name,
    required this.macrosLabel,
    required this.caloriesLabel,
  });

  final MealType meal;
  final String name;
  final String macrosLabel;
  final String caloriesLabel;
}

class DietPlanDayItem {
  const DietPlanDayItem({
    required this.dayNumber,
    required this.caloriesLabel,
    required this.isCompleted,
    required this.isToday,
    required this.isExpanded,
    required this.meals,
    required this.proteinLabel,
    required this.carbsLabel,
    required this.fatLabel,
  });

  final int dayNumber;
  final String caloriesLabel;
  final bool isCompleted;
  final bool isToday;
  final bool isExpanded;
  final List<DietPlanMealItem> meals;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;

  String get title => 'Day $dayNumber';
}

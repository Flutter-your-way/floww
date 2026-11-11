import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habit_day.dart';

class HabitRowItem {
  const HabitRowItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.valueLabel,
    required this.unitLabel,
    required this.captionLabel,
    required this.progress,
    required this.isCompleted,
    this.bonusLabel,
    this.sourceLabel,
    this.isRest = false,
    this.isAuto = false,
  });

  final String id;
  final String title;
  final HabitIconKind icon;
  final String valueLabel;
  final String unitLabel;
  final String captionLabel;
  final double progress;
  final bool isCompleted;
  final String? bonusLabel;
  final String? sourceLabel;
  final bool isRest;
  final bool isAuto;
}

class WeekdayProgressItem {
  const WeekdayProgressItem({
    required this.label,
    required this.percentLabel,
    required this.progress,
    required this.status,
  });

  final String label;
  final String percentLabel;
  final double progress;
  final HabitDayStatus status;
}

class CalendarDayItem {
  const CalendarDayItem({
    required this.label,
    required this.progress,
    required this.status,
    required this.isToday,
  });

  final String label;
  final double progress;
  final HabitDayStatus status;
  final bool isToday;
}

class HabitStreakItem {
  const HabitStreakItem({required this.title, required this.daysLabel});

  final String title;
  final String daysLabel;
}

class HabitLegendItem {
  const HabitLegendItem({required this.label, required this.status});

  final String label;
  final HabitDayStatus status;
}

class HabitSuggestionItem {
  const HabitSuggestionItem({
    required this.id,
    required this.title,
    required this.targetLabel,
    required this.icon,
  });

  final String id;
  final String title;
  final String targetLabel;
  final HabitIconKind icon;
}

class HabitStatItem {
  const HabitStatItem({
    required this.title,
    required this.value,
    required this.unit,
    this.icon,
  });

  final String title;
  final String value;
  final String unit;
  final HabitIconKind? icon;
}

class HabitOptionItem {
  const HabitOptionItem({required this.id, required this.label});

  final String id;
  final String label;
}

enum HabitHeatmapLevel { empty, low, medium, high, full }

class HabitHeatmapEntry {
  const HabitHeatmapEntry({
    required this.title,
    required this.detail,
    required this.status,
    required this.progress,
    required this.percentLabel,
  });

  final String title;
  final String detail;
  final HabitDayStatus status;
  final double progress;
  final String percentLabel;
}

class HabitHeatmapCell {
  const HabitHeatmapCell({
    required this.date,
    required this.level,
    required this.isToday,
    required this.weekdayLabel,
    required this.dateLabel,
    required this.summaryLabel,
    required this.completion,
    required this.percentLabel,
    required this.entries,
  });

  final DateTime date;
  final HabitHeatmapLevel level;
  final bool isToday;
  final String weekdayLabel;
  final String dateLabel;
  final String summaryLabel;
  final double completion;
  final String percentLabel;
  final List<HabitHeatmapEntry> entries;

  int countOf(HabitDayStatus status) =>
      entries.where((entry) => entry.status == status).length;
}

class HabitHeatmapMonth {
  const HabitHeatmapMonth({required this.weekIndex, required this.label});

  final int weekIndex;
  final String label;
}

class HabitHeatmapData {
  const HabitHeatmapData({
    required this.weeks,
    required this.months,
    required this.weekdayLabels,
    required this.summaryLabel,
  });

  static const empty = HabitHeatmapData(
    weeks: [],
    months: [],
    weekdayLabels: [],
    summaryLabel: '',
  );

  final List<List<HabitHeatmapCell?>> weeks;
  final List<HabitHeatmapMonth> months;
  final List<String?> weekdayLabels;
  final String summaryLabel;
}

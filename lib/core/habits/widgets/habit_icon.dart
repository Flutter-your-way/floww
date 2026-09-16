import 'package:flutter/material.dart';

import 'package:floww/core/habits/models/habit.dart';

class HabitIcon extends StatelessWidget {
  const HabitIcon({
    super.key,
    required this.kind,
    required this.size,
    required this.color,
  });

  final HabitIconKind kind;
  final double size;
  final Color color;

  static IconData iconOf(HabitIconKind kind) => switch (kind) {
    HabitIconKind.clipboard => Icons.assignment_outlined,
    HabitIconKind.book => Icons.menu_book_rounded,
    HabitIconKind.journal => Icons.auto_stories_rounded,
    HabitIconKind.coldShower => Icons.water_drop_outlined,
    HabitIconKind.stretching => Icons.fitness_center_rounded,
    HabitIconKind.sleep => Icons.bed_rounded,
    HabitIconKind.noSugar => Icons.check_rounded,
    HabitIconKind.dumbbell => Icons.fitness_center_rounded,
    HabitIconKind.walk => Icons.directions_walk_rounded,
    HabitIconKind.water => Icons.local_drink_rounded,
    HabitIconKind.meditation => Icons.self_improvement_rounded,
    HabitIconKind.screenFree => Icons.phone_iphone_rounded,
    HabitIconKind.flame => Icons.local_fire_department_rounded,
    HabitIconKind.trophy => Icons.emoji_events_rounded,
    HabitIconKind.trend => Icons.trending_up_rounded,
    HabitIconKind.target => Icons.track_changes_rounded,
  };

  @override
  Widget build(BuildContext context) =>
      Icon(iconOf(kind), size: size, color: color);
}

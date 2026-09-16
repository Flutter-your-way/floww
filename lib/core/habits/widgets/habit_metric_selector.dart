import 'package:flutter/material.dart';

import 'package:floww/core/habits/widgets/habit_chevron_button.dart';

class HabitMetricSelector extends StatelessWidget {
  const HabitMetricSelector({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HabitChevronButton(label: label, onPressed: onPressed);
  }
}

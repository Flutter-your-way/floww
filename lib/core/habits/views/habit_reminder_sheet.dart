import 'package:flutter/material.dart';

import 'package:floww/config/widgets/pickers/floww_time_picker.dart';
import 'package:floww/core/habits/view_models/habit_rules_view_model.dart';
import 'package:floww/core/habits/views/habit_option_sheet.dart';

class HabitReminderSheet {
  HabitReminderSheet._();

  static Future<void> show({
    required BuildContext context,
    required HabitRulesViewModel rules,
  }) async {
    String? selected;
    await HabitOptionSheet.show(
      context: context,
      title: rules.reminderLabel,
      subtitle: rules.reminderSheetSubtitle,
      items: rules.reminderItems,
      selectedId: rules.reminderId,
      onSelect: (id) {
        selected = id;
        rules.selectReminder(id);
      },
    );
    final id = selected;
    if (id == null || !rules.isCustomReminder(id) || !context.mounted) return;
    final initial = rules.reminderPickerMinutes;
    final picked = await FlowwTimePicker.show(
      context,
      initialTime: TimeOfDay(
        hour: initial ~/ TimeOfDay.minutesPerHour,
        minute: initial % TimeOfDay.minutesPerHour,
      ),
    );
    if (picked == null) return;
    rules.setReminder(picked.hour * TimeOfDay.minutesPerHour + picked.minute);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/config/widgets/tabs/app_chip_tabs.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/view_models/habit_rules_view_model.dart';
import 'package:floww/core/habits/views/habit_option_sheet.dart';
import 'package:floww/core/habits/widgets/habit_chevron_button.dart';
import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';

class HabitRulesFields extends StatelessWidget {
  const HabitRulesFields({super.key});

  void _openSchedule(BuildContext context, HabitRulesViewModel rules) {
    HapticManager.light();
    HabitOptionSheet.show(
      context: context,
      title: rules.scheduleLabel,
      subtitle: rules.scheduleSheetSubtitle,
      items: rules.scheduleItems,
      selectedId: rules.scheduleId,
      onSelect: rules.selectSchedule,
    );
  }

  void _openSource(BuildContext context, HabitRulesViewModel rules) {
    HapticManager.light();
    HabitOptionSheet.show(
      context: context,
      title: rules.sourceLabel,
      subtitle: rules.sourceSheetSubtitle,
      items: rules.sourceItems,
      selectedId: rules.source.name,
      onSelect: rules.selectSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitRulesViewModel>(
      builder: (context, rules, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetFieldLabel(label: rules.goalLabel),
            SizedBox(height: AppSpacing.lg),
            AppChipTabs<HabitGoalType>(
              items: rules.goalTypes,
              selected: rules.goalType,
              labelOf: rules.labelOfGoal,
              onSelected: (goalType) {
                HapticManager.selection();
                rules.selectGoal(goalType);
              },
            ),
            SizedBox(height: AppSpacing.xl2),
            AppSheetFieldLabel(label: rules.scheduleLabel),
            SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: HabitChevronButton(
                label: rules.scheduleValueLabel,
                onPressed: () => _openSchedule(context, rules),
              ),
            ),
            if (rules.showsWeekdays) ...[
              SizedBox(height: AppSpacing.lg),
              WeekdayPicker(
                items: rules.weekdayItems,
                onToggle: rules.toggleWeekday,
              ),
            ],
            if (rules.showsSource) ...[
              SizedBox(height: AppSpacing.xl2),
              AppSheetFieldLabel(label: rules.sourceLabel),
              SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: HabitChevronButton(
                  label: rules.sourceValueLabel,
                  onPressed: () => _openSource(context, rules),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

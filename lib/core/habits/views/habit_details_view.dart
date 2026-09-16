import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/habits/models/habit_period.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/habit_details_view_model.dart';
import 'package:floww/core/habits/views/edit_habit_sheet.dart';
import 'package:floww/core/habits/views/habit_option_sheet.dart';
import 'package:floww/core/habits/widgets/habit_detail_header_card.dart';
import 'package:floww/core/habits/widgets/habit_progress_calendar_card.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class HabitDetailsView extends StatelessWidget {
  const HabitDetailsView({super.key});

  void _openEdit(BuildContext context, HabitDetailsViewModel viewModel) {
    HapticManager.light();
    EditHabitSheet.show(context: context, viewModel: viewModel);
  }

  void _openPeriods(BuildContext context, HabitDetailsViewModel viewModel) {
    HapticManager.light();
    HabitOptionSheet.show(
      context: context,
      title: viewModel.periodSheetTitle,
      subtitle: viewModel.periodSheetSubtitle,
      items: [
        for (final period in viewModel.periods)
          HabitOptionItem(
            id: period.name,
            label: viewModel.labelOfPeriod(period),
          ),
      ],
      selectedId: viewModel.period.name,
      onSelect: (id) => viewModel.selectPeriod(
        HabitPeriod.values.firstWhere(
          (period) => period.name == id,
          orElse: () => viewModel.period,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitDetailsViewModel>(
      builder: (context, viewModel, child) {
        return InnerPageScaffold(
          title: viewModel.title,
          onBack: () => NavigationService.instance.pop(),
          children: [
            if (!viewModel.hasHabit)
              TipCard.note(title: viewModel.missingLabel)
            else ...[
              HabitDetailHeaderCard(
                icon: viewModel.habitIcon,
                title: viewModel.habitTitle,
                description: viewModel.habitDescription,
                editLabel: viewModel.editLabel,
                stats: viewModel.stats,
                onEdit: () => _openEdit(context, viewModel),
              ),
              SizedBox(height: AppSpacing.lg),
              HabitProgressCalendarCard(
                title: viewModel.progressTitle,
                periodLabel: viewModel.periodLabel,
                weekdayLabels: viewModel.weekdayLabels,
                days: viewModel.days,
                legend: viewModel.legend,
                onSelectPeriod: () => _openPeriods(context, viewModel),
              ),
              SizedBox(height: AppSpacing.lg),
              TipCard(
                title: viewModel.aboutTitle,
                message: viewModel.aboutMessage,
                icon: Icons.graphic_eq_rounded,
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/premium/widgets/premium_gate.dart';
import 'package:floww/core/premium/widgets/premium_locked_card.dart';
import 'package:floww/core/habits/models/habit_reminder_setting.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/add_habit_view_model.dart';
import 'package:floww/core/habits/view_models/habit_rules_view_model.dart';
import 'package:floww/core/habits/views/custom_habit_sheet.dart';
import 'package:floww/core/habits/views/habit_reminder_sheet.dart';
import 'package:floww/core/habits/widgets/habit_suggestion_tile.dart';
import 'package:floww/core/habits/widgets/wave_suggestion_card.dart';

typedef HabitSuggestionCallback =
    Future<void> Function(
      HabitSuggestion suggestion,
      HabitReminderSetting reminder,
    );

class AddHabitSheet extends StatelessWidget {
  const AddHabitSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required List<HabitSuggestion> suggestions,
    required List<HabitSuggestionGroup> groups,
    required HabitSuggestionCallback onAdd,
    required CustomHabitCallback onCreateCustom,
  }) async {
    final choice = await showAppFloatingSheet<AddHabitChoice>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            AddHabitViewModel(suggestions: suggestions, groups: groups),
        child: const AddHabitSheet(),
      ),
    );
    if (choice == null || !context.mounted) return;
    final suggestion = choice.suggestion;
    if (suggestion == null) {
      await CustomHabitSheet.show(context: context, onCreate: onCreateCustom);
      return;
    }
    final rules = HabitRulesViewModel(
      reminderMinutes: HabitReminderSetting.defaultMinutesFor(suggestion.icon),
    );
    await HabitReminderSheet.show(context: context, rules: rules);
    final reminder = rules.reminder;
    rules.dispose();
    HapticManager.success();
    await onAdd(suggestion, reminder);
  }

  void _add(
    BuildContext context,
    AddHabitViewModel viewModel,
    HabitSuggestionItem item,
  ) {
    final suggestion = viewModel.suggestionOf(item.id);
    if (suggestion == null) return;
    HapticManager.selection();
    Navigator.of(context).pop(AddHabitChoice.suggestion(suggestion));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddHabitViewModel>(
      builder: (context, viewModel, child) {
        final suggestions = viewModel.suggestions;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewModel.hasSuggestionGroup) ...[
                  PremiumGate(
                    capability: PremiumCapability.personalizedRecommendations,
                    placeholder: const SizedBox.shrink(),
                    locked: const PremiumLockedCard(
                      capability: PremiumCapability.personalizedRecommendations,
                    ),
                    child: WaveSuggestionCard(
                      label: viewModel.waveLabel,
                      title: viewModel.groupTitle,
                      actionLabel: viewModel.tryAnotherLabel,
                      items: viewModel.groupItems,
                      onTryAnother: viewModel.canTryAnother
                          ? viewModel.nextGroup
                          : null,
                      onAdd: (item) => _add(context, viewModel, item),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
                if (suggestions.isEmpty)
                  _EmptySuggestions(message: viewModel.emptyMessage)
                else
                  HabitSuggestionGrid(
                    items: suggestions,
                    onSelect: (item) => _add(context, viewModel, item),
                  ),
              ],
            ),
            footer: Align(
              child: IntrinsicWidth(
                child: PillButton(
                  label: viewModel.createCustomLabel,
                  icon: Icons.add_rounded,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                  onPressed: () =>
                      Navigator.of(context).pop(const AddHabitChoice.custom()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddHabitChoice {
  const AddHabitChoice.custom() : suggestion = null;

  const AddHabitChoice.suggestion(HabitSuggestion this.suggestion);

  final HabitSuggestion? suggestion;
}

class _EmptySuggestions extends StatelessWidget {
  const _EmptySuggestions({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmallRegularTight.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

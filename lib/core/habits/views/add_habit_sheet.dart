import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/core/habits/models/habit_suggestion.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/view_models/add_habit_view_model.dart';
import 'package:floww/core/habits/views/custom_habit_sheet.dart';
import 'package:floww/core/habits/widgets/habit_suggestion_tile.dart';
import 'package:floww/core/habits/widgets/wave_suggestion_card.dart';

typedef HabitSuggestionCallback = void Function(HabitSuggestion suggestion);

class AddHabitSheet extends StatelessWidget {
  const AddHabitSheet({super.key, required this.onAdd});

  final HabitSuggestionCallback onAdd;

  static Future<void> show({
    required BuildContext context,
    required List<HabitSuggestion> suggestions,
    required List<HabitSuggestionGroup> groups,
    required HabitSuggestionCallback onAdd,
    required CustomHabitCallback onCreateCustom,
  }) async {
    final wantsCustom = await showAppFloatingSheet<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            AddHabitViewModel(suggestions: suggestions, groups: groups),
        child: AddHabitSheet(onAdd: onAdd),
      ),
    );
    if (wantsCustom != true || !context.mounted) return;
    await CustomHabitSheet.show(context: context, onCreate: onCreateCustom);
  }

  void _add(
    BuildContext context,
    AddHabitViewModel viewModel,
    HabitSuggestionItem item,
  ) {
    final suggestion = viewModel.suggestionOf(item.id);
    if (suggestion == null) return;
    HapticManager.success();
    onAdd(suggestion);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddHabitViewModel>(
      builder: (context, viewModel, child) {
        final suggestions = viewModel.suggestions;

        return AppFloatingSheet(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSheetHeader(
                    title: viewModel.title,
                    subtitle: viewModel.subtitle,
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  if (viewModel.hasSuggestionGroup) ...[
                    WaveSuggestionCard(
                      label: viewModel.waveLabel,
                      title: viewModel.groupTitle,
                      actionLabel: viewModel.tryAnotherLabel,
                      items: viewModel.groupItems,
                      onTryAnother: viewModel.canTryAnother
                          ? viewModel.nextGroup
                          : null,
                      onAdd: (item) => _add(context, viewModel, item),
                    ),
                    SizedBox(height: AppSpacing.xl2),
                  ],
                  if (suggestions.isEmpty)
                    _EmptySuggestions(message: viewModel.emptyMessage)
                  else
                    HabitSuggestionGrid(
                      items: suggestions,
                      onSelect: (item) => _add(context, viewModel, item),
                    ),
                  SizedBox(height: AppSpacing.xl2),
                  Align(
                    child: IntrinsicWidth(
                      child: PillButton(
                        label: viewModel.createCustomLabel,
                        icon: Icons.add_rounded,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl3,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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

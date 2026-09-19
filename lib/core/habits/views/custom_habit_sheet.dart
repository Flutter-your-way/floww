import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_header.dart';
import 'package:floww/core/habits/models/habit_draft.dart';
import 'package:floww/core/habits/view_models/custom_habit_view_model.dart';
import 'package:floww/core/habits/widgets/habit_text_field.dart';
import 'package:floww/core/habits/widgets/habit_unit_dropdown.dart';

typedef CustomHabitCallback = Future<void> Function(HabitDraft draft);

class CustomHabitSheet extends StatelessWidget {
  const CustomHabitSheet({super.key, required this.onCreate});

  final CustomHabitCallback onCreate;

  static Future<void> show({
    required BuildContext context,
    required CustomHabitCallback onCreate,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => CustomHabitViewModel(),
        child: CustomHabitSheet(onCreate: onCreate),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    CustomHabitViewModel viewModel,
  ) async {
    final draft = viewModel.buildDraft();
    if (draft == null) return;
    HapticManager.success();
    await onCreate(draft);
    if (context.mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomHabitViewModel>(
      builder: (context, viewModel, child) {
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
                  AppSheetFieldLabel(label: viewModel.nameLabel),
                  SizedBox(height: AppSpacing.lg),
                  HabitTextField(
                    hint: viewModel.nameHint,
                    onChanged: viewModel.updateName,
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  AppSheetFieldLabel(label: viewModel.descriptionLabel),
                  SizedBox(height: AppSpacing.lg),
                  HabitTextField(
                    hint: viewModel.descriptionHint,
                    onChanged: viewModel.updateDescription,
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  AppSheetFieldLabel(label: viewModel.targetLabel),
                  SizedBox(height: AppSpacing.lg),
                  HabitTextField(
                    hint: viewModel.targetHint,
                    isNumeric: true,
                    onChanged: viewModel.updateTarget,
                    trailing: HabitUnitDropdown(
                      metric: viewModel.metric,
                      metrics: viewModel.metrics,
                      labelOf: viewModel.labelOf,
                      onSelected: viewModel.selectMetric,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl2),
                  Align(
                    child: IntrinsicWidth(
                      child: PillButton(
                        label: viewModel.submitLabel,
                        icon: Icons.add_rounded,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl3,
                        ),
                        onPressed: viewModel.canSubmit
                            ? () => _submit(context, viewModel)
                            : null,
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

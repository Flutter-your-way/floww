import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/buttons/select_buttons/weekday_picker.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/models/program_start_config.dart';
import 'package:floww/core/workout/view_models/program_start_view_model.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

class ProgramStartSheet extends StatelessWidget {
  const ProgramStartSheet({super.key, required this.onStart});

  static Future<void> show({
    required BuildContext context,
    required ProgramStartSetup setup,
    required ValueChanged<ProgramStartConfig> onStart,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ProgramStartViewModel(setup),
        child: ProgramStartSheet(onStart: onStart),
      ),
    );
  }

  final ValueChanged<ProgramStartConfig> onStart;

  void _toggle(ProgramStartViewModel viewModel, int weekday) {
    if (!viewModel.toggleWeekday(weekday)) HapticManager.warning();
  }

  void _submit(BuildContext context, ProgramStartViewModel viewModel) {
    HapticManager.success();
    final config = viewModel.config;
    Navigator.of(context).maybePop();
    onStart(config);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramStartViewModel>(
      builder: (context, viewModel, child) {
        final colors = context.colors;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: SectionLabel(label: viewModel.daysLabel)),
                    Text(
                      viewModel.daysHint,
                      style: AppTypography.labelSmallMedium.copyWith(
                        color: viewModel.isDaysComplete
                            ? colors.textSecondary
                            : colors.accentOrange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                WeekdayPicker(
                  items: viewModel.weekdayItems,
                  onToggle: (weekday) => _toggle(viewModel, weekday),
                ),
                SizedBox(height: AppSpacing.xl2),
                SectionLabel(label: viewModel.lengthLabel),
                SizedBox(height: AppSpacing.md),
                ValueStepper(
                  target: viewModel.weeksTarget,
                  onAdjust: viewModel.adjustWeeks,
                ),
                SizedBox(height: AppSpacing.xl2),
                SectionLabel(label: viewModel.startLabel),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final option in viewModel.startOptions)
                      SelectableChip(
                        label: option.label,
                        isSelected: option.isSelected,
                        onTap: () {
                          HapticManager.selection();
                          viewModel.selectStartDay(option.value);
                        },
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  viewModel.summary,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            footer: PillButton(
              label: viewModel.submitLabel,
              icon: Icons.play_arrow_rounded,
              onPressed: viewModel.canStart
                  ? () => _submit(context, viewModel)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

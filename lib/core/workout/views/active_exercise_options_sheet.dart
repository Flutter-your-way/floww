import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/active_option_row.dart';

class ActiveExerciseOptionsSheet extends StatelessWidget {
  const ActiveExerciseOptionsSheet({super.key});

  static Future<ActiveOptionAction?> show(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) {
    return showAppFloatingSheet<ActiveOptionAction>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const ActiveExerciseOptionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final options = viewModel.options;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.optionsTitle,
            icon: Icons.tune_rounded,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) SizedBox(height: AppSpacing.sm),
                  ActiveOptionRow(
                    option: options[i],
                    onTap: () {
                      HapticManager.selection();
                      Navigator.of(context).pop(options[i].action);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

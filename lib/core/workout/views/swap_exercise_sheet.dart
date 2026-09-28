import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/placeholders/app_section_loader.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/exercise_picker_row.dart';

class SwapExerciseSheet extends StatelessWidget {
  const SwapExerciseSheet({super.key});

  static const double _listMaxHeight = AppSizes.s160 * 2;

  static Future<void> show(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) {
    viewModel.loadAlternatives();
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const SwapExerciseSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final alternatives = viewModel.alternatives;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.swapTitle,
            subtitle: viewModel.swapSubtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: viewModel.isLoadingAlternatives
                ? const AppSectionLoader()
                : alternatives.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      viewModel.swapEmptyMessage,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: _listMaxHeight,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < alternatives.length; i++) ...[
                            if (i > 0) SizedBox(height: AppSpacing.sm),
                            ExercisePickerRow(
                              exercise: alternatives[i],
                              onTap: () {
                                HapticManager.success();
                                viewModel.swapTo(alternatives[i].id);
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

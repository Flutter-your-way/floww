import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/active_workout_view_model.dart';
import 'package:floww/core/workout/widgets/exercise_info_section_card.dart';

class ExerciseTechniqueSheet extends StatelessWidget {
  const ExerciseTechniqueSheet({super.key});

  static Future<void> show(
    BuildContext context,
    ActiveWorkoutViewModel viewModel,
  ) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const ExerciseTechniqueSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutViewModel>(
      builder: (context, viewModel, child) {
        final title = viewModel.currentEntry?.name;
        if (title == null) return const SizedBox.shrink();
        final sections = viewModel.techniqueSections;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: title,
            subtitle: viewModel.techniqueSubtitle,
            icon: Icons.menu_book_rounded,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) SizedBox(height: AppSpacing.lg),
                  ExerciseInfoSectionCard(
                    section: sections[i],
                    onToggle: () => viewModel.toggleSection(sections[i].id),
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

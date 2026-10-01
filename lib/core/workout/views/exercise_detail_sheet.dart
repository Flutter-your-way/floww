import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/models/exercise_view_data.dart';
import 'package:floww/core/workout/view_models/exercise_library_view_model.dart';
import 'package:floww/core/workout/widgets/exercise_info_section_card.dart';
import 'package:floww/core/workout/widgets/muscle_activation_card.dart';
import 'package:floww/core/workout/widgets/workout_stat_tile.dart';

class ExerciseDetailSheet extends StatelessWidget {
  const ExerciseDetailSheet({super.key});

  static const double _mediaAspectRatio = 16 / 9;

  static Future<void> show({
    required BuildContext context,
    required ExerciseLibraryViewModel viewModel,
    required String exerciseId,
  }) {
    viewModel.openDetail(exerciseId);
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const ExerciseDetailSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseLibraryViewModel>(
      builder: (context, viewModel, child) {
        final detail = viewModel.detail;
        if (detail == null) return const SizedBox.shrink();

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: detail.name,
            subtitle: detail.subtitle,
            onClose: () => Navigator.of(context).maybePop(),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: _mediaAspectRatio,
                    child: RemoteImage(
                      url: detail.imageUrl,
                      fallbackIcon: Icons.fitness_center,
                      fallbackIconSize: AppSizes.s40,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _ExerciseStatsCard(detail: detail),
                SizedBox(height: AppSpacing.lg),
                TipCard.inline(
                  title: 'Suggested target',
                  message: detail.targetLabel,
                  icon: Icons.track_changes,
                ),
                if (detail.muscles.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  MuscleActivationCard(
                    title: 'Muscles Worked',
                    muscles: detail.muscles,
                  ),
                ],
                for (final section in detail.sections) ...[
                  SizedBox(height: AppSpacing.lg),
                  ExerciseInfoSectionCard(
                    section: section,
                    onToggle: () => viewModel.toggleSection(section.id),
                  ),
                ],
              ],
            ),
            footer: PillButton(
              variant: detail.isSaved
                  ? PillButtonVariant.outline
                  : PillButtonVariant.accent,
              label: viewModel.saveLabelOf(detail),
              icon: detail.isSaved
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              onPressed: () {
                HapticManager.selection();
                viewModel.toggleSaved(detail.id);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ExerciseStatsCard extends StatelessWidget {
  const _ExerciseStatsCard({required this.detail});

  final ExerciseDetailItem detail;

  @override
  Widget build(BuildContext context) {
    final stats = detail.stats;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.lg),
            Expanded(child: WorkoutStatTile(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

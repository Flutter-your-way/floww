import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/core/workout/models/workout_completion_view_data.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/workout/widgets/recovery_mood_selector.dart';

class RecoveryCheckInSheet extends StatelessWidget {
  const RecoveryCheckInSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required WorkoutCompletionViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const RecoveryCheckInSheet(),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WorkoutCompletionViewModel viewModel,
  ) async {
    HapticManager.success();
    await viewModel.saveRecovery();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  void _skip(BuildContext context) {
    HapticManager.light();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutCompletionViewModel>(
      builder: (context, viewModel, child) {
        final recovery = viewModel.recovery;
        final colors = context.colors;

        return AppFloatingSheet(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CircularHeaderButton(
                    icon: Icons.close_rounded,
                    size: AppSizes.s40,
                    iconSize: AppSizes.s20,
                    backgroundColor: colors.backgroundPrimary,
                    onPressed: () => _skip(context),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  recovery.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading1.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  recovery.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLargeMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xl2),
                RecoveryMoodSelector(
                  moods: recovery.moods,
                  selected: viewModel.selectedMood,
                  onSelected: (mood) {
                    HapticManager.selection();
                    viewModel.selectMood(mood);
                  },
                ),
                SizedBox(height: AppSpacing.xl2),
                _RecoveryActions(
                  recovery: recovery,
                  canSave: viewModel.canSaveRecovery,
                  onSkip: () => _skip(context),
                  onSave: () => _save(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecoveryActions extends StatelessWidget {
  const _RecoveryActions({
    required this.recovery,
    required this.canSave,
    required this.onSkip,
    required this.onSave,
  });

  final RecoveryCheckInItem recovery;
  final bool canSave;
  final VoidCallback onSkip;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PillButton(
            variant: PillButtonVariant.neutral,
            label: recovery.skipLabel,
            onPressed: onSkip,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: PillButton(
            label: recovery.saveLabel,
            icon: Icons.check_rounded,
            onPressed: canSave ? onSave : null,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/view_models/workout_completion_view_model.dart';
import 'package:floww/core/yoga/view_models/yoga_self_check_view_model.dart';
import 'package:floww/config/widgets/cards/app_bullet_card.dart';
import 'package:floww/core/yoga/widgets/yoga_rating_row.dart';

class YogaSelfCheckSheet extends StatelessWidget {
  const YogaSelfCheckSheet({super.key});

  static Future<void> show({
    required BuildContext context,
    required WorkoutCompletionViewModel viewModel,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => YogaSelfCheckViewModel(
          viewModel.sessionService,
          viewModel.sessionId,
        ),
        child: const YogaSelfCheckSheet(),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    YogaSelfCheckViewModel viewModel,
  ) async {
    HapticManager.success();
    final saved = await viewModel.save();
    if (saved && context.mounted) Navigator.of(context).pop();
  }

  void _skip(BuildContext context) {
    HapticManager.light();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaSelfCheckViewModel>(
      builder: (context, viewModel, child) {
        final colors = context.colors;
        final errorMessage = viewModel.errorMessage;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            onClose: () => _skip(context),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.minLabel,
                      style: AppTypography.captionSemiBold.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    Text(
                      viewModel.maxLabel,
                      style: AppTypography.captionSemiBold.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
                for (var i = 0; i < viewModel.statements.length; i++) ...[
                  SizedBox(height: AppSpacing.xl),
                  YogaRatingRow(
                    statement: viewModel.statements[i],
                    scale: viewModel.scale,
                    selected: viewModel.ratingAt(i),
                    onSelected: (value) {
                      HapticManager.selection();
                      viewModel.rate(i, value);
                    },
                  ),
                ],
                SizedBox(height: AppSpacing.xl2),
                AppBulletCard(
                  title: 'Reflect',
                  icon: Icons.self_improvement,
                  items: viewModel.reflections,
                ),
                if (errorMessage != null) ...[
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    errorMessage,
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.destructive,
                    ),
                  ),
                ],
              ],
            ),
            footer: Row(
              children: [
                Expanded(
                  child: PillButton(
                    variant: PillButtonVariant.neutral,
                    label: 'Skip',
                    onPressed: () => _skip(context),
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: PillButton(
                    label: 'Save',
                    icon: Icons.check_rounded,
                    isLoading: viewModel.isSaving,
                    onPressed: viewModel.canSave
                        ? () => _save(context, viewModel)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

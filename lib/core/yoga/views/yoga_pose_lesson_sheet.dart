import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/widgets/exercise_info_section_card.dart';
import 'package:floww/core/yoga/data/yoga_postures_data.dart';
import 'package:floww/core/yoga/models/yoga_profile.dart';
import 'package:floww/core/yoga/view_models/yoga_lesson_view_model.dart';

class YogaPoseLessonSheet extends StatelessWidget {
  const YogaPoseLessonSheet({super.key});

  static const double _mediaAspectRatio = 16 / 9;

  static Future<void> show({
    required BuildContext context,
    required String postureId,
    required YogaProfile profile,
  }) async {
    final posture = YogaPosturesData.byId(postureId);
    if (posture == null) return;
    HapticManager.light();
    await showAppFloatingSheet<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => YogaLessonViewModel(posture, profile),
        child: const YogaPoseLessonSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YogaLessonViewModel>(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: _mediaAspectRatio,
                    child: RemoteImage(
                      url: viewModel.imageUrl,
                      fallbackIcon: Icons.self_improvement,
                      fallbackIconSize: AppSizes.s40,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  viewModel.summary,
                  style: AppTypography.bodyMediumRegular.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (viewModel.isCautioned) ...[
                  SizedBox(height: AppSpacing.lg),
                  TipCard.inline(
                    title: viewModel.cautionTitle,
                    message: viewModel.cautionMessage,
                    icon: Icons.health_and_safety_outlined,
                  ),
                ],
                for (final section in viewModel.sections) ...[
                  SizedBox(height: AppSpacing.lg),
                  ExerciseInfoSectionCard(
                    section: section,
                    onToggle: () {
                      HapticManager.selection();
                      viewModel.toggle(section.id);
                    },
                  ),
                ],
                SizedBox(height: AppSpacing.lg),
                Text(
                  viewModel.disclaimer,
                  style: AppTypography.bodySmallItalic.copyWith(
                    color: colors.textTertiary,
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

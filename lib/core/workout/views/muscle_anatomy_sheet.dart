import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/muscle_activation_row.dart';
import 'package:floww/core/workout/widgets/muscle_figures.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MuscleAnatomySheet extends StatelessWidget {
  const MuscleAnatomySheet({super.key, required this.anatomy});

  static Future<void> show({
    required BuildContext context,
    required MuscleAnatomyItem anatomy,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => MuscleAnatomySheet(anatomy: anatomy),
    );
  }

  final MuscleAnatomyItem anatomy;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Muscle Anatomy',
        titleStyle: context.textTheme.headlineSmall,
        subtitle: anatomy.subtitle,
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(
              variant: AppCardVariant.sunken,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl2,
              ),
              child: MuscleFigures(
                height: AppSizes.s160,
                spacing: AppSpacing.xl,
                labelled: true,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _ActivationDetailCard(muscles: anatomy.muscles),
            SizedBox(height: AppSpacing.lg),
            TipCard.stacked(
              title: 'Recovery Tip',
              message: anatomy.recoveryTip,
              icon: Icons.lightbulb,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivationDetailCard extends StatelessWidget {
  const _ActivationDetailCard({required this.muscles});

  final List<MuscleFocusEntry> muscles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel(label: 'Activation Detail'),
          SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < muscles.length; i++) ...[
            if (i > 0) ...[
              SizedBox(height: AppSpacing.xl),
              Container(height: AppSizes.s1, color: colors.borderSubtle),
              SizedBox(height: AppSpacing.xl),
            ],
            MuscleActivationRow(
              muscle: muscles[i],
              nameStyle: AppTypography.heading4SemiBold.copyWith(
                color: colors.textPrimary,
              ),
              valueStyle: AppTypography.bodyMediumRegular.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

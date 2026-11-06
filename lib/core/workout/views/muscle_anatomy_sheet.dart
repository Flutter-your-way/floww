import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/cards/tip_card.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/muscle_activation_card.dart';
import 'package:floww/core/workout/widgets/muscle_figures.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class MuscleAnatomySheet extends StatelessWidget {
  const MuscleAnatomySheet({
    super.key,
    required this.anatomy,
    required this.templateOf,
  });

  static Future<void> show({
    required BuildContext context,
    required MuscleAnatomyItem anatomy,
    required MuscleMapTemplate? Function(MuscleBodySide side) templateOf,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) =>
          MuscleAnatomySheet(anatomy: anatomy, templateOf: templateOf),
    );
  }

  final MuscleAnatomyItem anatomy;
  final MuscleMapTemplate? Function(MuscleBodySide side) templateOf;

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Muscle Anatomy',
        subtitle: anatomy.subtitle,
        onClose: () => NavigationService.instance.pop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(
              variant: AppCardVariant.sunken,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: MuscleFigures(
                targets: anatomy.targets,
                templateOf: templateOf,
                height: AppSizes.s160,
                spacing: AppSpacing.xl,
                labelled: true,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            MuscleActivationCard(muscles: anatomy.muscles),
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

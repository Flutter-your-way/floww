import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/muscle_activation_row.dart';

class MuscleActivationCard extends StatelessWidget {
  const MuscleActivationCard({
    super.key,
    required this.muscles,
    this.title = 'Activation Detail',
  });

  final List<MuscleFocusEntry> muscles;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionLabel(label: title),
          SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < muscles.length; i++) ...[
            if (i > 0) ...[
              SizedBox(height: AppSpacing.lg),
              Container(height: AppSizes.s1, color: colors.borderSubtle),
              SizedBox(height: AppSpacing.lg),
            ],
            MuscleActivationRow(
              muscle: muscles[i],
              nameStyle: AppTypography.labelMediumSemiBold.copyWith(
                color: colors.textPrimary,
              ),
              valueStyle: AppTypography.bodyXSmallMedium.copyWith(
                color: colors.textSecondary,
              ),
              barHeight: AppSizes.s6,
            ),
          ],
        ],
      ),
    );
  }
}

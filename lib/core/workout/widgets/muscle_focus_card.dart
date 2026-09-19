import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/muscle_activation_row.dart';
import 'package:floww/core/workout/widgets/muscle_figures.dart';
import 'package:floww/core/workout/widgets/workout_chip.dart';

class MuscleFocusCard extends StatelessWidget {
  const MuscleFocusCard({super.key, required this.muscles, this.onViewAnatomy});

  final List<MuscleFocusEntry> muscles;
  final VoidCallback? onViewAnatomy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Muscle Focus',
            titleStyle: AppTypography.heading4SemiBold.copyWith(
              color: colors.textPrimary,
            ),
            trailing: WorkoutChip(
              label: 'View Anatomy',
              tone: WorkoutChipTone.accent,
              onTap: onViewAnatomy,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MuscleFigures(),
              SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < muscles.length; i++) ...[
                      if (i > 0) SizedBox(height: AppSpacing.lg),
                      MuscleActivationRow(muscle: muscles[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

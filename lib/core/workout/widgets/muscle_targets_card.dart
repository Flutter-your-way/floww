import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/recovery/models/muscle_body_side.dart';
import 'package:floww/core/recovery/models/muscle_emphasis.dart';
import 'package:floww/core/recovery/services/muscle_map_service.dart';
import 'package:floww/core/recovery/widgets/muscle_emphasis_palette.dart';
import 'package:floww/core/workout/models/muscle_targets_item.dart';
import 'package:floww/core/workout/widgets/muscle_figures.dart';

class MuscleTargetsCard extends StatelessWidget {
  const MuscleTargetsCard({
    super.key,
    required this.item,
    required this.templateOf,
    this.figureHeight = AppSizes.s120,
  });

  final MuscleTargetsItem item;
  final MuscleMapTemplate? Function(MuscleBodySide side) templateOf;
  final double figureHeight;

  @override
  Widget build(BuildContext context) {
    final primaryLabel = item.primaryLabel;
    final secondaryLabel = item.secondaryLabel;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: item.title,
            titleStyle: AppTypography.heading4SemiBold.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              MuscleFigures(
                targets: item.targets,
                templateOf: templateOf,
                height: figureHeight,
              ),
              SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (primaryLabel != null)
                      _EmphasisLegend(
                        emphasis: MuscleEmphasis.primary,
                        muscles: primaryLabel,
                      ),
                    if (primaryLabel != null && secondaryLabel != null)
                      SizedBox(height: AppSpacing.xl),
                    if (secondaryLabel != null)
                      _EmphasisLegend(
                        emphasis: MuscleEmphasis.secondary,
                        muscles: secondaryLabel,
                      ),
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

class _EmphasisLegend extends StatelessWidget {
  const _EmphasisLegend({required this.emphasis, required this.muscles});

  final MuscleEmphasis emphasis;
  final String muscles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: AppSizes.s10,
              height: AppSizes.s10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emphasis.mapColor(colors),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              emphasis.label.toUpperCase(),
              style: AppTypography.captionSemiBold.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          muscles,
          style: AppTypography.bodySmallMediumTight.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

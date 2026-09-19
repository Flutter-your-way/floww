import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/segmented_level_bar.dart';

class TrainingEffectCard extends StatelessWidget {
  const TrainingEffectCard({super.key, required this.effect, this.onInfo});

  final TrainingEffectItem effect;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Training Effect',
            onTap: onInfo,
            titleStyle: AppTypography.heading4SemiBold.copyWith(
              color: colors.textPrimary,
            ),
            titleTrailing: Icon(
              Icons.info_outline,
              size: AppSizes.s16,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    effect.score,
                    style: AppTypography.bodyXXLargeBold.copyWith(
                      color: colors.primaryAlt,
                    ),
                  ),
                  Text(
                    effect.rating,
                    style: AppTypography.labelSmallMedium.copyWith(
                      color: colors.primaryAlt,
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effect.summary,
                      style: AppTypography.bodySmallRegularTight.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    SegmentedLevelBar(
                      filled: effect.filledSegments,
                      total: effect.totalSegments,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            effect.recoveryLabel,
                            style: AppTypography.bodySmallRegularTight.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.lg),
                        Text(
                          effect.recoveryValue,
                          style: AppTypography.bodySmallMediumTight.copyWith(
                            color: colors.primaryAlt,
                          ),
                        ),
                      ],
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

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MicronutrientSummaryCard extends StatelessWidget {
  const MicronutrientSummaryCard({
    super.key,
    required this.kind,
    required this.label,
    required this.amountLabel,
    required this.goalLabel,
    required this.progress,
    required this.percentLabel,
    required this.statusLabel,
    required this.isOverLimit,
  });

  final MicronutrientKind kind;
  final String label;
  final String amountLabel;
  final String goalLabel;
  final double progress;
  final String percentLabel;
  final String statusLabel;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isOverLimit ? colors.destructiveBorder : colors.primary;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return AppCard(
      variant: AppCardVariant.sunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.s40,
                height: AppSizes.s40,
                decoration: AppShapes.decoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(kind.icon, color: color, size: AppSizes.s20),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(goalLabel, style: captionStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppProgressBar(progress: progress, color: color),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: Text(percentLabel, style: captionStyle)),
              Text(
                statusLabel,
                style: captionStyle?.copyWith(
                  color: isOverLimit ? color : colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

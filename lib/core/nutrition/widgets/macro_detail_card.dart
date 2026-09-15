import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/macro_nutrient.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/macro_split_bar.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';
import 'package:floww/config/theme/app_shapes.dart';

class MacroSplitCard extends StatelessWidget {
  const MacroSplitCard({super.key, required this.title, required this.shares});

  final String title;
  final List<MacroShare> shares;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.highlighted,
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.bodySmall),
          SizedBox(height: AppSpacing.md),
          MacroSplitBar(shares: shares),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in shares)
                Text(
                  '${item.macro.label} ${item.shareLabel}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: item.macro.colorOf(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MacroDetailCard extends StatelessWidget {
  const MacroDetailCard({
    super.key,
    required this.macro,
    required this.amountLabel,
    required this.goalLabel,
    required this.progress,
    required this.percentOfGoalLabel,
    required this.energyLabel,
    required this.recommendedLabel,
  });

  final MacroNutrient macro;
  final String amountLabel;
  final String goalLabel;
  final double progress;
  final String percentOfGoalLabel;
  final String energyLabel;
  final String recommendedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = macro.colorOf(context);
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return AppCard(
      variant: AppCardVariant.sunken,
      borderColor: color.withValues(alpha: AppOpacity.tintBorder),
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
                  side: BorderSide(
                    color: color.withValues(alpha: AppOpacity.tintBorder),
                  ),
                ),
                child: Icon(macro.icon, color: color, size: AppSizes.s20),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      macro.tabLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      macro.tagline,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
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
              Expanded(child: Text(percentOfGoalLabel, style: captionStyle)),
              Text(energyLabel, style: captionStyle),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            macro.description,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppShapes.decoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRO TIPS',
                  style: context.textTheme.labelSmall?.copyWith(color: color),
                ),
                for (final tip in macro.tips) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Container(
                          width: AppSizes.s6,
                          height: AppSizes.s6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(tip, style: context.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: AppShapes.decoration(
              color: color.withValues(alpha: AppOpacity.tintFill),
              borderRadius: BorderRadius.circular(AppRadius.full),
              side: BorderSide(color: color),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Recommended: ',
                style: context.textTheme.labelMedium?.copyWith(color: color),
                children: [
                  TextSpan(
                    text: recommendedLabel,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

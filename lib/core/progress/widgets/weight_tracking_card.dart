import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/progress/view_models/progress_view_model.dart';
import 'package:floww/core/progress/widgets/progress_card_empty_state.dart';
import 'package:floww/core/progress/widgets/weight_line_chart.dart';

class WeightTrackingCard extends StatelessWidget {
  const WeightTrackingCard({
    super.key,
    required this.viewModel,
    this.onAddWeight,
    this.onUnlogWeight,
  });

  final ProgressViewModel viewModel;
  final VoidCallback? onAddWeight;
  final VoidCallback? onUnlogWeight;

  @override
  Widget build(BuildContext context) {
    final hasEntries = viewModel.weight.hasEntries;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: viewModel.weightTitle,
            titleStyle: AppTypography.heading4SemiBold,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.canUnlogWeight) ...[
                  PillButton(
                    variant: PillButtonVariant.outline,
                    height: AppSizes.s28,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    label: viewModel.unlogWeightLabel,
                    labelStyle: AppTypography.captionSemiBold,
                    labelColor: context.colors.textSecondary,
                    onPressed: onUnlogWeight,
                  ),
                  SizedBox(width: AppSpacing.md),
                ],
                PillButton(
                  variant: PillButtonVariant.glass,
                  height: AppSizes.s28,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  label: viewModel.addWeightLabel,
                  labelStyle: AppTypography.captionSemiBold,
                  onPressed: onAddWeight,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          if (!hasEntries) ...[
            ProgressCardEmptyState(
              icon: Icons.monitor_weight_outlined,
              title: viewModel.weightEmptyTitle,
              message: viewModel.weightEmptyMessage,
              buttonLabel: viewModel.logWeightLabel,
              onPressed: onAddWeight,
            ),
            SizedBox(height: AppSpacing.xl),
            _WeightGoalRow(viewModel: viewModel),
          ] else ...[
            _WeightHeadline(viewModel: viewModel),
            SizedBox(height: AppSpacing.lg),
            _WeightPaceBanner(label: viewModel.weightPaceLabel),
            SizedBox(height: AppSpacing.xl),
            WeightLineChart(
              samples: viewModel.weightSamples,
              axisLabels: viewModel.weightAxisLabels,
              dateLabels: viewModel.weightDateLabels,
              minValue: viewModel.weightAxisMin,
              maxValue: viewModel.weightAxisMax,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightHeadline extends StatelessWidget {
  const _WeightHeadline({required this.viewModel});

  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final changeColor = viewModel.isLosingWeight
        ? colors.primaryAlt
        : colors.accentOrange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          viewModel.weightValueLabel,
          style: AppTypography.bodyHeadlineBoldTight.copyWith(
            color: colors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: Text(
            viewModel.weightUnit,
            style: AppTypography.bodyXSmallRegular.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                viewModel.isLosingWeight
                    ? Icons.south_east_rounded
                    : Icons.north_east_rounded,
                size: AppSizes.s12,
                color: changeColor,
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                viewModel.weightChangeLabel,
                style: AppTypography.bodySmallMediumTight.copyWith(
                  color: changeColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.weightTargetLabel,
                style: AppTypography.labelSmallRegular.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                viewModel.weightTargetValueLabel,
                style: AppTypography.bodySmallMediumTight.copyWith(
                  color: colors.accentOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeightPaceBanner extends StatelessWidget {
  const _WeightPaceBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: AppShapes.decoration(
        color: colors.primary.withValues(alpha: AppOpacity.tintFill),
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_down_rounded,
            size: AppSizes.s12,
            color: colors.primary,
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmallBoldTight.copyWith(
                color: colors.primaryAlt,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightGoalRow extends StatelessWidget {
  const _WeightGoalRow({required this.viewModel});

  static const double _dotSize = AppSizes.s8;

  final ProgressViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryAlt,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            viewModel.weightTargetPillLabel,
            style: AppTypography.bodySmallMediumTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: AppProgressBar(
              progress: viewModel.weightGoalProgress,
              height: AppSizes.s6,
              color: colors.primaryAlt,
              trackColor: colors.borderSubtle,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            viewModel.weightGoalProgressLabel,
            style: AppTypography.bodySmallMediumTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveInjurySwapCard extends StatelessWidget {
  const WaveInjurySwapCard({
    super.key,
    required this.swap,
    required this.isResolved,
    required this.onApply,
    required this.onKeep,
  });

  final WaveInjurySwap swap;
  final bool isResolved;
  final VoidCallback onApply;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      headerColor: context.colors.destructiveTint,
      header: Row(
        children: [
          Text('🚨', style: AppTypography.bodyLargeMedium),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              swap.title,
              style: AppTypography.bodyLargeBold.copyWith(
                color: context.colors.destructiveBorder,
              ),
            ),
          ),
        ],
      ),
      sections: [
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: WaveSectionLabel(label: 'REPLACING'),
              ),
              SizedBox(height: AppSpacing.lg),
              _SwapPreview(swap: swap),
              SizedBox(height: AppSpacing.xl),
              Text(
                swap.rationale,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.accent,
                      label: 'Apply Changes',
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyLargeBold,
                      onPressed: isResolved ? null : onApply,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: PillButton(
                      variant: PillButtonVariant.glass,
                      label: 'Keep Original',
                      height: AppSizes.s44,
                      labelStyle: AppTypography.bodyLargeBold,
                      labelColor: context.colors.textPrimary,
                      onPressed: isResolved ? null : onKeep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwapPreview extends StatelessWidget {
  const _SwapPreview({required this.swap});

  final WaveInjurySwap swap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwapSide(
              label: 'Removing',
              value: swap.removing,
              valueColor: context.colors.destructiveBorder,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(
            Icons.arrow_downward_rounded,
            size: AppSizes.s18,
            color: context.colors.primary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SwapSide(
              label: 'Adding',
              value: swap.adding,
              valueColor: context.colors.primary,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapSide extends StatelessWidget {
  const _SwapSide({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.alignment,
  });

  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTrailing = alignment == CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: isTrailing ? TextAlign.right : TextAlign.left,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textDim,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          textAlign: isTrailing ? TextAlign.right : TextAlign.left,
          style: AppTypography.bodyMediumBold.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

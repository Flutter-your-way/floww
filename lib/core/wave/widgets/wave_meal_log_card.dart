import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/core/wave/models/wave_card_data.dart';
import 'package:floww/core/wave/widgets/wave_card.dart';

class WaveMealLogCard extends StatelessWidget {
  const WaveMealLogCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.foods,
    required this.selectedSlot,
    required this.totals,
    required this.isSelected,
    required this.onSlotSelected,
    required this.onFoodToggled,
    required this.onLogMeal,
  });

  static const _columns = 4;

  final String title;
  final String subtitle;
  final List<WaveQuickFood> foods;
  final WaveMealSlot selectedSlot;
  final WaveMealTotals totals;
  final bool Function(WaveQuickFood food) isSelected;
  final ValueChanged<WaveMealSlot> onSlotSelected;
  final ValueChanged<WaveQuickFood> onFoodToggled;
  final VoidCallback onLogMeal;

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.bodyMediumBold),
          SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSubtle,
            ),
          ),
        ],
      ),
      sections: [
        WaveCardSection(
          child: Row(
            children: [
              for (final slot in WaveMealSlot.values) ...[
                if (slot != WaveMealSlot.values.first)
                  SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MealSlotTile(
                    slot: slot,
                    isSelected: slot == selectedSlot,
                    onTap: () => onSlotSelected(slot),
                  ),
                ),
              ],
            ],
          ),
        ),
        WaveCardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WaveSectionLabel(label: 'QUICK ADD'),
              SizedBox(height: AppSpacing.lg),
              for (var start = 0; start < foods.length; start += _columns) ...[
                if (start > 0) SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (
                      var index = start;
                      index < start + _columns && index < foods.length;
                      index++
                    ) ...[
                      if (index > start) SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickFoodTile(
                          food: foods[index],
                          isSelected: isSelected(foods[index]),
                          onTap: () => onFoodToggled(foods[index]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!totals.isEmpty) _MealTotalsRow(totals: totals),
        if (!totals.isEmpty)
          WaveCardSection(
            child: PillButton(
              variant: PillButtonVariant.accent,
              icon: Icons.add_rounded,
              label: totals.logLabel,
              height: AppSizes.s48,
              labelStyle: AppTypography.bodyLargeBold,
              onPressed: onLogMeal,
            ),
          ),
      ],
    );
  }
}

class _MealSlotTile extends StatelessWidget {
  const _MealSlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final WaveMealSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.press,
        curve: AppMotion.expandCurve,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.bgTinted : colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.borderSubtle,
            width: AppSizes.s1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(slot.emoji, style: AppTypography.bodyMediumMedium),
            SizedBox(height: AppSpacing.sm),
            Text(
              slot.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: isSelected ? colors.primary : colors.textSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFoodTile extends StatelessWidget {
  const _QuickFoodTile({
    required this.food,
    required this.isSelected,
    required this.onTap,
  });

  final WaveQuickFood food;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AnimatedContainer(
            duration: AppMotion.press,
            curve: AppMotion.expandCurve,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.md,
            ),
            decoration: AppShapes.decoration(
              color: isSelected ? colors.bgTinted : colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(
                color: isSelected ? colors.primary : colors.borderSubtle,
                width: AppSizes.s1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(food.emoji, style: AppTypography.bodyLargeMedium),
                SizedBox(height: AppSpacing.sm),
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmallSemiBold,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  '${food.calories} kcal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionMedium.copyWith(
                    color: colors.textDim,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Container(
                height: AppSizes.s16,
                width: AppSizes.s16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: AppSizes.s10,
                  color: colors.backgroundPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealTotalsRow extends StatelessWidget {
  const _MealTotalsRow({required this.totals});

  final WaveMealTotals totals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return WaveCardSection(
      child: Row(
        children: [
          _MacroTotal(
            value: totals.calories,
            unit: 'kcal',
            color: colors.accentOrange,
          ),
          SizedBox(width: AppSpacing.lg),
          _MacroTotal(
            value: totals.protein,
            unit: 'pro',
            color: colors.proteinAccent,
          ),
          SizedBox(width: AppSpacing.lg),
          _MacroTotal(
            value: totals.carbs,
            unit: 'carb',
            color: colors.carbsAccent,
          ),
          SizedBox(width: AppSpacing.lg),
          _MacroTotal(
            value: totals.fat,
            unit: 'fat',
            color: colors.fatAccent,
          ),
          const Spacer(),
          Text(
            totals.itemCountLabel,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroTotal extends StatelessWidget {
  const _MacroTotal({
    required this.value,
    required this.unit,
    required this.color,
  });

  final int value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: AppTypography.bodyMediumBold.copyWith(color: color),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          unit,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textDim,
          ),
        ),
      ],
    );
  }
}

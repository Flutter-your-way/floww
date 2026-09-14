import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/compact_text_field.dart';
import 'package:floww/core/nutrition/widgets/nutrition_section_label.dart';
import 'package:floww/config/theme/app_shapes.dart';

class WaterQuickAddCard extends StatelessWidget {
  const WaterQuickAddCard({
    super.key,
    required this.amounts,
    required this.isCustomOpen,
    required this.customHint,
    required this.isSaving,
    required this.onAdd,
    required this.onToggleCustom,
    required this.onCustomChanged,
    this.onAddCustom,
  });

  final List<WaterQuickAmount> amounts;
  final bool isCustomOpen;
  final String customHint;
  final bool isSaving;
  final ValueChanged<WaterQuickAmount> onAdd;
  final VoidCallback onToggleCustom;
  final ValueChanged<String> onCustomChanged;
  final VoidCallback? onAddCustom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: NutritionSectionLabel(label: 'Quick add')),
              GestureDetector(
                onTap: onToggleCustom,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  isCustomOpen ? 'Cancel' : '+ Custom Intake',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < amounts.length; i++) ...[
                if (i > 0) SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickAmountButton(
                    amount: amounts[i],
                    onTap: isSaving ? null : () => onAdd(amounts[i]),
                  ),
                ),
              ],
            ],
          ),
          if (isCustomOpen) ...[
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CompactTextField(
                    hintText: customHint,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: onCustomChanged,
                    onSubmitted: (_) => onAddCustom?.call(),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                PillButton(
                  label: 'Add',
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
                  isLoading: isSaving,
                  onPressed: onAddCustom,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({required this.amount, this.onTap});

  final WaterQuickAmount amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: AppShapes.decoration(
          color: colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(amount.label, style: context.textTheme.labelMedium),
            Text(
              amount.amountLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

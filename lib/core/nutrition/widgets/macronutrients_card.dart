import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/nutrition_colors.dart';

class MacronutrientsCard extends StatelessWidget {
  const MacronutrientsCard({super.key, required this.items, this.onLearnMore});

  final List<MacroProgressItem> items;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLearnMore,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              title: 'Macronutrients',
              trailing: Text(
                'Learn More',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: context.colors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) SizedBox(width: AppSpacing.lg),
                  Expanded(child: _MacroColumn(item: items[i])),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({required this.item});

  final MacroProgressItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.macro.colorOf(context);
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(item.macro.icon, color: color, size: AppSizes.s12),
            SizedBox(width: AppSpacing.xs),
            Text(item.macro.label, style: captionStyle),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              item.amountLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Text(
                item.goalLabel,
                overflow: TextOverflow.ellipsis,
                style: captionStyle,
              ),
            ),
            Text(item.percentLabel, style: captionStyle),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppProgressBar(progress: item.progress, color: color),
      ],
    );
  }
}

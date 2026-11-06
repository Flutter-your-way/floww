import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_collapsible_section.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class MicronutrientsCard extends StatelessWidget {
  const MicronutrientsCard({
    super.key,
    required this.limits,
    required this.items,
    required this.extendedItems,
    required this.showExtended,
    required this.toggleLabel,
    required this.onToggle,
    this.note,
    this.onOpenNutrient,
  });

  final List<MicronutrientRowItem> limits;
  final List<MicronutrientRowItem> items;
  final List<MicronutrientRowItem> extendedItems;
  final bool showExtended;
  final String toggleLabel;
  final VoidCallback onToggle;
  final String? note;
  final ValueChanged<MicronutrientKind>? onOpenNutrient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = this.note;
    final sectionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CardHeader(title: 'Micronutrients'),
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Fiber, limits and vitamins & minerals from your meals',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _MicronutrientRows(items: limits, onOpen: onOpenNutrient),
          SizedBox(height: AppSpacing.lg),
          Text('VITAMINS & MINERALS', style: sectionStyle),
          SizedBox(height: AppSpacing.xs),
          _MicronutrientRows(items: items),
          AppCollapsibleSection(
            visible: showExtended,
            child: _MicronutrientRows(
              items: extendedItems,
              leadingDivider: true,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _ToggleAction(label: toggleLabel, onTap: onToggle),
          if (note != null) ...[
            SizedBox(height: AppSpacing.lg),
            _MicronutrientNote(message: note),
          ],
        ],
      ),
    );
  }
}

class _MicronutrientRows extends StatelessWidget {
  const _MicronutrientRows({
    required this.items,
    this.onOpen,
    this.leadingDivider = false,
  });

  final List<MicronutrientRowItem> items;
  final ValueChanged<MicronutrientKind>? onOpen;
  final bool leadingDivider;

  @override
  Widget build(BuildContext context) {
    final onOpen = this.onOpen;

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0 || leadingDivider)
            Divider(
              height: AppSizes.s1,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
          _MicronutrientRow(
            item: items[i],
            onTap: _tapOf(items[i].kind, onOpen),
          ),
        ],
      ],
    );
  }

  VoidCallback? _tapOf(
    MicronutrientKind? kind,
    ValueChanged<MicronutrientKind>? onOpen,
  ) {
    if (kind == null || onOpen == null) return null;
    return () => onOpen(kind);
  }
}

class _MicronutrientRow extends StatelessWidget {
  const _MicronutrientRow({required this.item, this.onTap});

  final MicronutrientRowItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = item.isOverLimit ? colors.destructiveBorder : null;

    return PressScale(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.s96,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: AppProgressBar(progress: item.progress, animated: true),
            ),
            SizedBox(width: AppSpacing.md),
            SizedBox(
              width: AppSizes.s108,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    text: item.amountLabel,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: accent ?? colors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: ' / ${item.goalLabel}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.s16,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleAction extends StatelessWidget {
  const _ToggleAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: AnimatedSwitcher(
          duration: AppMotion.expand,
          switchInCurve: AppMotion.expandCurve,
          switchOutCurve: AppMotion.collapseCurve,
          child: Text(
            label,
            key: ValueKey(label),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmallSemiBold.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _MicronutrientNote extends StatelessWidget {
  const _MicronutrientNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: AppSizes.s16,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';

class MicronutrientBreakdown extends StatelessWidget {
  const MicronutrientBreakdown({
    super.key,
    required this.limits,
    required this.items,
    this.note,
    this.onOpenNutrient,
  });

  final List<MicronutrientRowItem> limits;
  final List<MicronutrientRowItem> items;
  final String? note;
  final ValueChanged<MicronutrientKind>? onOpenNutrient;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    final sectionStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('FIBER & LIMITS', style: sectionStyle),
        SizedBox(height: AppSpacing.xs),
        _MicronutrientRows(items: limits, onOpen: onOpenNutrient),
        SizedBox(height: AppSpacing.lg),
        Text('VITAMINS & MINERALS', style: sectionStyle),
        SizedBox(height: AppSpacing.xs),
        _MicronutrientRows(items: items),
        if (note != null) ...[
          SizedBox(height: AppSpacing.lg),
          _MicronutrientNote(message: note),
        ],
      ],
    );
  }
}

class _MicronutrientRows extends StatelessWidget {
  const _MicronutrientRows({required this.items, this.onOpen});

  final List<MicronutrientRowItem> items;
  final ValueChanged<MicronutrientKind>? onOpen;

  @override
  Widget build(BuildContext context) {
    final onOpen = this.onOpen;

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
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

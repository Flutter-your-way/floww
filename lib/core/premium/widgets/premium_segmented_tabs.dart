import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class PremiumSegmentedTabs<T> extends StatelessWidget {
  const PremiumSegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.badgeOf,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelOf;
  final String? Function(T item)? badgeOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final badgeOf = this.badgeOf;
    final count = items.length;
    final selectedIndex = items.indexOf(selected);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: context.colors.borderSubtle,
          width: AppSizes.s1,
        ),
      ),
      child: Stack(
        children: [
          if (count > 0 && selectedIndex >= 0)
            Positioned.fill(
              child: AnimatedAlign(
                duration: AppMotion.expand,
                curve: AppMotion.expandCurve,
                alignment: Alignment(
                  count > 1 ? -1 + 2 * selectedIndex / (count - 1) : 0,
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / count,
                  heightFactor: 1,
                  child: const _SegmentIndicator(),
                ),
              ),
            ),
          Row(
            children: [
              for (final item in items)
                Expanded(
                  child: _Segment(
                    label: labelOf(item),
                    badge: badgeOf == null ? null : badgeOf(item),
                    isSelected: item == selected,
                    onTap: () => onSelected(item),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentIndicator extends StatelessWidget {
  const _SegmentIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: AppShapes.decoration(
        gradient: context.gradients.primaryButton,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.surfaceTranslucent, width: AppSizes.s1),
        shadows: [
          BoxShadow(
            color: colors.primary.withValues(alpha: AppOpacity.buttonGlow),
            offset: const Offset(0, AppSizes.s4),
            blurRadius: AppSizes.s12,
            spreadRadius: -AppSizes.s4,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badge = this.badge;
    final foreground = isSelected
        ? colors.backgroundPrimary
        : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppSizes.s52,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.expand,
                curve: AppMotion.expandCurve,
                style: AppTypography.labelLargeSemiBold.copyWith(
                  color: foreground,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: AppSpacing.sm),
              AnimatedDefaultTextStyle(
                duration: AppMotion.expand,
                curve: AppMotion.expandCurve,
                style: AppTypography.labelSmallMedium.copyWith(
                  color: foreground,
                ),
                child: Text(badge, maxLines: 1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

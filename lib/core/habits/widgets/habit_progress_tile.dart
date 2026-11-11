import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/habits/models/habit.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';
import 'package:floww/core/habits/widgets/habit_icon.dart';

class HabitProgressTile extends StatelessWidget {
  const HabitProgressTile({
    super.key,
    required this.item,
    this.onToggle,
    this.onOpen,
  });

  final HabitRowItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onOpen;

  void _open() {
    HapticManager.light();
    onOpen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = item.isRest ? colors.textQuiet : colors.textPrimary;
    final canToggle = onToggle != null && !item.isAuto;

    return GestureDetector(
      onTap: onOpen == null ? null : _open,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        variant: item.isCompleted
            ? AppCardVariant.highlighted
            : AppCardVariant.subtle,
        radius: AppRadius.md,
        padding: const EdgeInsets.all(AppSpacing.lg),
        transitionDuration: AppMotion.expand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HabitBadge(icon: item.icon, isCompleted: item.isCompleted),
                const Spacer(),
                _HabitCheckButton(
                  isCompleted: item.isCompleted,
                  onTap: canToggle ? onToggle : null,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMediumSemiBold.copyWith(
                color: titleColor,
              ),
            ),
            const Spacer(),
            SizedBox(height: AppSpacing.md),
            _HabitValueRow(item: item),
            SizedBox(height: AppSpacing.sm),
            AppProgressBar(
              progress: item.progress,
              height: AppSizes.s6,
              trackColor: colors.borderSubtle,
              animated: true,
            ),
            SizedBox(height: AppSpacing.sm),
            _HabitCaptionRow(
              caption: item.captionLabel,
              source: item.sourceLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class HabitProgressGrid extends StatelessWidget {
  const HabitProgressGrid({
    super.key,
    required this.items,
    this.onToggle,
    this.onOpen,
  });

  static const int _columns = 2;

  final List<HabitRowItem> items;
  final void Function(HabitRowItem item)? onToggle;
  final void Function(HabitRowItem item)? onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index += _columns) ...[
          if (index > 0) SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _GridCell(item: items[index], grid: this),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: index + 1 < items.length
                      ? _GridCell(item: items[index + 1], grid: this)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.item, required this.grid});

  final HabitRowItem item;
  final HabitProgressGrid grid;

  @override
  Widget build(BuildContext context) {
    final onToggle = grid.onToggle;
    final onOpen = grid.onOpen;

    return HabitProgressTile(
      key: ValueKey(item.id),
      item: item,
      onToggle: onToggle == null ? null : () => onToggle(item),
      onOpen: onOpen == null ? null : () => onOpen(item),
    );
  }
}

class _HabitBadge extends StatelessWidget {
  const _HabitBadge({required this.icon, required this.isCompleted});

  final HabitIconKind icon;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: AppMotion.expand,
      curve: AppMotion.expandCurve,
      width: AppSizes.s32,
      height: AppSizes.s32,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: isCompleted ? colors.tintStrong : colors.bgTinted,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: HabitIcon(kind: icon, size: AppSizes.s16, color: colors.primary),
    );
  }
}

class _HabitCheckButton extends StatelessWidget {
  const _HabitCheckButton({required this.isCompleted, this.onTap});

  final bool isCompleted;
  final VoidCallback? onTap;

  void _toggle() {
    HapticManager.light();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isInteractive = onTap != null;
    final outlineColor = isInteractive ? colors.textPrimary : colors.textFaint;

    return GestureDetector(
      onTap: isInteractive ? _toggle : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSizes.s32,
        height: AppSizes.s32,
        child: Align(
          alignment: Alignment.topRight,
          child: AnimatedSwitcher(
            duration: AppMotion.expand,
            switchInCurve: AppMotion.pop,
            switchOutCurve: AppMotion.collapseCurve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(isCompleted),
              size: AppSizes.s24,
              color: isCompleted ? colors.primaryAlt : outlineColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitValueRow extends StatelessWidget {
  const _HabitValueRow({required this.item});

  final HabitRowItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bonus = item.bonusLabel;

    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.valueLabel,
                    style: AppTypography.bodyXLargeBold.copyWith(
                      color: item.isRest
                          ? colors.textQuiet
                          : colors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' ${item.unitLabel}',
                    style: AppTypography.bodySmallMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
        ),
        if (bonus != null) ...[
          SizedBox(width: AppSpacing.xs),
          _HabitBonusChip(label: bonus),
        ],
      ],
    );
  }
}

class _HabitBonusChip extends StatelessWidget {
  const _HabitBonusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: AppShapes.decoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: colors.borderGlow, width: AppSizes.s1),
      ),
      child: Text(
        label,
        style: AppTypography.captionSemiBold.copyWith(color: colors.primaryAlt),
      ),
    );
  }
}

class _HabitCaptionRow extends StatelessWidget {
  const _HabitCaptionRow({required this.caption, this.source});

  final String caption;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    final style = AppTypography.bodyXSmallMedium.copyWith(color: color);
    final sourceLabel = source;

    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (sourceLabel != null) ...[
          SizedBox(width: AppSpacing.xs),
          Icon(Icons.sync_rounded, size: AppSizes.s10, color: color),
          SizedBox(width: AppSpacing.xxs),
          Text(sourceLabel, style: style),
        ],
      ],
    );
  }
}

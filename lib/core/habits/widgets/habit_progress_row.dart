import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/habits/models/habits_view_data.dart';

class HabitProgressRow extends StatelessWidget {
  const HabitProgressRow({
    super.key,
    required this.item,
    this.onToggle,
    this.onOpen,
  });

  final HabitRowItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onOpen;

  void _toggle() {
    HapticManager.light();
    onToggle?.call();
  }

  void _open() {
    HapticManager.light();
    onOpen?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentColor = item.isCompleted || item.isRest
        ? colors.textQuiet
        : colors.textPrimary;
    final tagLabel = item.tagLabel;

    return GestureDetector(
      onTap: onToggle == null ? null : _toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _HabitCheckIcon(isCompleted: item.isCompleted),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StrikeThroughTitle(
                        title: item.title,
                        color: contentColor,
                        isStruck: item.isCompleted,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    AnimatedDefaultTextStyle(
                      duration: AppMotion.expand,
                      curve: AppMotion.expandCurve,
                      style: AppTypography.bodySmallMediumTight.copyWith(
                        color: contentColor,
                      ),
                      child: Text(item.progressLabel),
                    ),
                    if (onOpen != null) ...[
                      SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: _open,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.s20,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (tagLabel != null) ...[
                  SizedBox(height: AppSpacing.xxs),
                  _HabitRowTag(
                    label: tagLabel,
                    icon: item.isRest
                        ? Icons.bedtime_outlined
                        : Icons.sync_rounded,
                  ),
                ],
                SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  progress: item.progress,
                  height: AppSizes.s8,
                  color: colors.primaryAlt,
                  trackColor: colors.borderSubtle,
                  animated: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCheckIcon extends StatelessWidget {
  const _HabitCheckIcon({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedSwitcher(
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
        color: isCompleted ? colors.primaryAlt : colors.textPrimary,
      ),
    );
  }
}

class _StrikeThroughTitle extends StatelessWidget {
  const _StrikeThroughTitle({
    required this.title,
    required this.color,
    required this.isStruck,
  });

  final String title;
  final Color color;
  final bool isStruck;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedDefaultTextStyle(
            duration: AppMotion.expand,
            curve: AppMotion.expandCurve,
            style: AppTypography.labelLargeMedium.copyWith(color: color),
            child: Text(title, overflow: TextOverflow.ellipsis),
          ),
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: isStruck ? 1 : 0),
              duration: AppMotion.medium,
              curve: AppMotion.expandCurve,
              builder: (context, value, child) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(widthFactor: value, child: child),
              ),
              child: AnimatedContainer(
                duration: AppMotion.expand,
                height: AppSizes.s2,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitRowTag extends StatelessWidget {
  const _HabitRowTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;

    return Row(
      children: [
        Icon(icon, size: AppSizes.s12, color: color),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmallRegularTight.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

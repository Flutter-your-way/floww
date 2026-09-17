import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/core/wave/models/wave_quick_action.dart';

class WaveQuickActionBar extends StatelessWidget {
  const WaveQuickActionBar({
    super.key,
    required this.actions,
    required this.onSelected,
  });

  final List<WaveQuickAction> actions;
  final ValueChanged<WaveQuickAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (final action in actions) ...[
            if (action != actions.first) SizedBox(width: AppSpacing.md),
            _QuickActionChip(
              action: action,
              onTap: () => onSelected(action),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action, required this.onTap});

  final WaveQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        height: AppSizes.s36,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: AppShapes.decoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: AppSizes.s16, color: colors.primary),
            SizedBox(width: AppSpacing.sm),
            Text(
              action.label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

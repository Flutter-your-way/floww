import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/workout/models/workout_tab.dart';

class WorkoutTabBar extends StatelessWidget {
  const WorkoutTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<WorkoutTab> tabs;
  final WorkoutTab selected;
  final ValueChanged<WorkoutTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: context.sizes.screenHorizontalPadding,
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            _WorkoutTab(
              label: tab.label,
              isSelected: tab == selected,
              onTap: () => onSelected(tab),
            ),
        ],
      ),
    );
  }
}

class _WorkoutTab extends StatelessWidget {
  const _WorkoutTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 180);

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _duration,
        height: AppSizes.s40,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
        decoration: AppShapes.decoration(
          color: isSelected
              ? colors.backgroundPrimary
              : colors.backgroundPrimary.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: context.textTheme.titleMedium?.copyWith(
            color: isSelected ? colors.primary : colors.backgroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

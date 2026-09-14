import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppChipTabs<T> extends StatelessWidget {
  const AppChipTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Chip(
              label: labelOf(items[i]),
              isSelected: items[i] == selected,
              onTap: () => onSelected(items[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
        duration: const Duration(milliseconds: 180),
        height: AppSizes.s36,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: AppShapes.decoration(
          color: isSelected ? colors.tint : colors.backgroundSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: isSelected ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

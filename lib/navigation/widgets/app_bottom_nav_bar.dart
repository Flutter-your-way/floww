import 'package:floww/navigation/views/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<NavTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s64,
      // padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: context.colors.borderSubtle, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / items.length;
          final indicatorLeft =
              selectedIndex * segmentWidth + (segmentWidth - AppSizes.s48) / 2;
          final indicatorTop = (constraints.maxHeight - AppSizes.s48) / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                top: indicatorTop,
                width: AppSizes.s48,
                height: AppSizes.s48,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.backgroundElevated,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: _NavTabButton(
                      item: items[index],
                      isSelected: isSelected,
                      onTap: () => onTabSelected(index),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavTabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final targetColor = isSelected
        ? context.colors.textPrimary
        : context.colors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: targetColor),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            builder: (context, animatedColor, child) => SvgPicture.asset(
              item.iconAsset,
              width: AppSizes.s20,
              height: AppSizes.s20,
              colorFilter: ColorFilter.mode(
                animatedColor ?? targetColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

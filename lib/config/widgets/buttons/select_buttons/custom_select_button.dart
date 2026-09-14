import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomSelectButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const CustomSelectButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;

    final borderColor = isSelected
        ? themeColors.primary
        : const Color(0xFF181818);
    final textColor = isSelected ? themeColors.primary : Colors.white;

    final backgroundColor = isSelected
        ? Color.alphaBlend(
            themeColors.primary.withValues(alpha: 0.08),
            const Color(0xFF1F1F1F),
          )
        : const Color(0xFF1F1F1F);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: width,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: AppShapes.decoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: AppTypography.bodyMediumMedium.copyWith(color: textColor),
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/theme/app_shapes.dart';

class CustomSelectCardButton extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;
  final String? svgIcon;
  final IconData? iconData;
  final double? width;

  const CustomSelectCardButton({
    super.key,
    required this.title,
    this.description,
    required this.isSelected,
    required this.onTap,
    this.svgIcon,
    this.iconData,
    this.width,
  }) : assert(svgIcon != null || iconData != null, 'Either svgIcon or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;

    // Define border color based on state
    final borderColor = isSelected ? themeColors.primary : const Color(0xFF181818);

    // The background color is always solid #1F1F1F for this card style
    const backgroundColor = Color(0xFF1F1F1F);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: AppShapes.decoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconBox(themeColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLargeMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMediumRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(Color primaryColor) {
    final iconBoxColor = isSelected ? primaryColor.withValues(alpha: 0.08) : const Color(0xFF181818);
    final activeIconColor = isSelected ? primaryColor : Colors.white.withValues(alpha: 0.5);

    return Container(
      width: 40,
      height: 40,
      decoration: AppShapes.decoration(
        color: iconBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: svgIcon != null
          ? SvgPicture.asset(
              svgIcon!,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                activeIconColor,
                BlendMode.srcIn,
              ),
            )
          : Icon(
              iconData,
              size: 20,
              color: activeIconColor,
            ),
    );
  }
}

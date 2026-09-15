import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.titleTrailing,
    this.trailingText,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? titleStyle;
  final Widget? titleTrailing;
  final String? trailingText;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final titleTrailing = this.titleTrailing;
    final trailingText = this.trailingText;
    final trailing = this.trailing;
    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: titleStyle ?? context.textTheme.titleLarge,
          ),
        ),
        if (titleTrailing != null) ...[
          SizedBox(width: AppSpacing.md),
          titleTrailing,
        ],
        if (trailingText != null) ...[
          SizedBox(width: AppSpacing.sm),
          Text(
            trailingText,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? context.colors.primary,
              size: iconSize ?? AppSizes.s20,
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          if (trailing != null || showChevron)
            Expanded(child: titleRow)
          else
            Flexible(child: titleRow),
          if (trailing != null) ...[SizedBox(width: AppSpacing.md), trailing],
          if (showChevron)
            Icon(
              Icons.chevron_right,
              color: context.colors.textSecondary,
              size: AppSizes.s20,
            ),
        ],
      ),
    );
  }
}

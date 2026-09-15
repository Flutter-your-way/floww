import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';

class AppSheetPanel extends StatelessWidget {
  const AppSheetPanel({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.subtitle,
    this.icon,
    this.onClose,
    this.titleStyle,
  });

  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final IconData? icon;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final footer = this.footer;
    final icon = this.icon;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.xl2),
          Row(
            children: [
              if (icon != null) ...[
                _SheetTitleBadge(icon: icon),
                SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style:
                      titleStyle ??
                      context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              CircularHeaderButton(
                icon: Icons.close_rounded,
                size: AppSizes.s28,
                iconSize: AppSizes.s16,
                backgroundColor: context.colors.backgroundPrimary,
                onPressed: onClose,
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xl),
          Flexible(child: SingleChildScrollView(child: body)),
          if (footer != null) ...[SizedBox(height: AppSpacing.xl), footer],
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SheetTitleBadge extends StatelessWidget {
  const _SheetTitleBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.s24,
      height: AppSizes.s24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: AppSizes.s14,
        color: context.colors.backgroundPrimary,
      ),
    );
  }
}

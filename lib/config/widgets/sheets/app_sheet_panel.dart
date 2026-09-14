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
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final footer = this.footer;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.xl2),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CircularHeaderButton(
                icon: Icons.close_rounded,
                size: AppSizes.s28,
                iconSize: AppSizes.s16,
                backgroundColor: context.colors.backgroundElevated,
                onPressed: onClose,
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.xl),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md),
          Flexible(child: SingleChildScrollView(child: body)),
          if (footer != null) ...[SizedBox(height: AppSpacing.xl), footer],
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: context.textTheme.displaySmall),
              SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.md),
        CircularHeaderButton(
          icon: Icons.close_rounded,
          size: AppSizes.s40,
          iconSize: AppSizes.s20,
          backgroundColor: context.colors.backgroundPrimary,
          onPressed: onClose ?? () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class AppSheetFieldLabel extends StatelessWidget {
  const AppSheetFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

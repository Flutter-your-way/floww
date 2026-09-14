import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_shapes.dart';

class ReadOnlyPill extends StatelessWidget {
  const ReadOnlyPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(color: context.colors.borderMedium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            color: context.colors.textSecondary,
            size: AppSizes.s20,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

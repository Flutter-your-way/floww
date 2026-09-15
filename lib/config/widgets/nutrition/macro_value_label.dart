import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class MacroValueLabel extends StatelessWidget {
  const MacroValueLabel({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.captionMedium.copyWith(
            color: context.colors.textDim,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.bodySmallBoldTight.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

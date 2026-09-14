import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class NutritionSectionLabel extends StatelessWidget {
  const NutritionSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.textMuted,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

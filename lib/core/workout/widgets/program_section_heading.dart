import 'package:flutter/material.dart';

import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';

class ProgramSectionHeading extends StatelessWidget {
  const ProgramSectionHeading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.bodyLargeRegular.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }
}

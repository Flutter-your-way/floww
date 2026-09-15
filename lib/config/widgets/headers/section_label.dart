import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.textTheme.bodySmall?.copyWith(
        color: color ?? context.colors.textMuted,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

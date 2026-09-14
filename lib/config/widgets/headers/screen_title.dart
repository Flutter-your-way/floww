import 'package:flutter/material.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.backgroundPrimary,
          ),
        ),
        Text(
          title,
          style: context.textTheme.displaySmall?.copyWith(
            color: context.colors.backgroundPrimary,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

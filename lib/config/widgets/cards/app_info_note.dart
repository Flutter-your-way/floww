import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class AppInfoNote extends StatelessWidget {
  const AppInfoNote({
    super.key,
    required this.text,
    this.icon = Icons.lock_outline_rounded,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textMuted;

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(icon, size: AppSizes.s14, color: color),
            ),
          ),
          TextSpan(text: text),
        ],
      ),
      style: context.textTheme.bodySmall?.copyWith(color: color),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/backgrounds/app_background.dart';

class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        safeAreaTop: false,
        mode: AppBackgroundMode.active(context),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: context.textTheme.displaySmall),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Coming soon',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

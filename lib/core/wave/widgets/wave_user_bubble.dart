import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveUserBubble extends StatelessWidget {
  const WaveUserBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: AppShapes.decoration(
          color: context.colors.bgTinted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: context.colors.borderAccent,
            width: AppSizes.s1,
          ),
        ),
        child: Text(text, style: context.textTheme.bodyMedium),
      ),
    );
  }
}

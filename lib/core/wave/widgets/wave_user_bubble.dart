import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveUserBubble extends StatelessWidget {
  const WaveUserBubble({super.key, required this.text});

  static const double maxWidthFactor = 0.8;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: maxWidthFactor,
        alignment: Alignment.centerRight,
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: AppShapes.decoration(
              gradient: context.gradients.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppSizes.s6),
              ),
            ),
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.scheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

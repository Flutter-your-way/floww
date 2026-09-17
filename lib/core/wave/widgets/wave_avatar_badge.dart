import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class WaveAvatarBadge extends StatelessWidget {
  const WaveAvatarBadge({super.key});

  static const _barHeights = [
    AppSizes.s8,
    AppSizes.s14,
    AppSizes.s20,
    AppSizes.s14,
    AppSizes.s8,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s40,
      width: AppSizes.s40,
      alignment: Alignment.center,
      decoration: AppShapes.decoration(
        color: context.colors.bgTinted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: context.colors.borderAccent,
          width: AppSizes.s1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var index = 0; index < _barHeights.length; index++) ...[
            if (index > 0) SizedBox(width: AppSpacing.xxs),
            Container(
              width: AppSizes.s2,
              height: _barHeights[index],
              decoration: AppShapes.decoration(
                color: context.colors.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

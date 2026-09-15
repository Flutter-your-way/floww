import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';

class SegmentedLevelBar extends StatelessWidget {
  const SegmentedLevelBar({
    super.key,
    required this.filled,
    required this.total,
  });

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.full);

    return Container(
      height: AppSizes.s12,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: AppShapes.decoration(
        color: colors.borderSubtle,
        borderRadius: radius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) SizedBox(width: AppSizes.s1),
            Expanded(
              child: DecoratedBox(
                decoration: AppShapes.decoration(
                  color: i < filled ? colors.primaryAlt : colors.borderSubtle,
                  borderRadius: radius,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/strength_view_data.dart';
import 'package:floww/core/progress/widgets/strength_radar_chart.dart';

class StrengthLevelEntryCard extends StatelessWidget {
  const StrengthLevelEntryCard({
    super.key,
    required this.title,
    required this.message,
    required this.axes,
    required this.onTap,
  });

  final String title;
  final String message;
  final List<StrengthRadarAxis> axes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: title,
              icon: Icons.fitness_center_rounded,
              titleStyle: AppTypography.heading4SemiBold,
              showChevron: true,
            ),
            SizedBox(height: AppSpacing.xl),
            StrengthRadarChart(axes: axes),
            SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: AppTypography.bodySmallMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

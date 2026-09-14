import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';

class DietPlanCard extends StatelessWidget {
  const DietPlanCard({
    super.key,
    required this.nextLabel,
    required this.daysLabel,
    required this.percentLabel,
    required this.progress,
    this.onTap,
  });

  final String nextLabel;
  final String daysLabel;
  final String percentLabel;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final captionStyle = context.textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(title: 'Diet Plan', showChevron: true),
            Text('Built by WAVE from your goals', style: captionStyle),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    nextLabel,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
                Text(daysLabel, style: captionStyle),
                SizedBox(width: AppSpacing.md),
                Text(
                  percentLabel,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            AppProgressBar(progress: progress),
          ],
        ),
      ),
    );
  }
}

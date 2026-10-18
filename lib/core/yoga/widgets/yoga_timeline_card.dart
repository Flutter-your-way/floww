import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/yoga/models/yoga_course_view_data.dart';

class YogaTimelineCard extends StatelessWidget {
  const YogaTimelineCard({super.key, required this.items});

  static const double _markerWidth = AppSizes.s72;

  final List<YogaTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              SizedBox(height: AppSpacing.lg),
              Container(height: AppSizes.s1, color: colors.borderSubtle),
              SizedBox(height: AppSpacing.lg),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _markerWidth,
                  child: Text(
                    items[i].range,
                    style: AppTypography.captionSemiBold.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title,
                        style: AppTypography.bodyMediumSemiBold.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        items[i].detail,
                        style: AppTypography.bodySmallRegularTight.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

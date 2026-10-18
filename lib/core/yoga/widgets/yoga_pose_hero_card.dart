import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_card_pop.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/config/widgets/images/remote_image.dart';
import 'package:floww/core/workout/widgets/active_metric_pill.dart';

class YogaPoseHeroCard extends StatelessWidget {
  const YogaPoseHeroCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.badgeLabel,
    required this.sectionLabel,
    required this.onInfo,
    this.sanskritName,
  });

  static const double _aspectRatio = 4 / 3;

  final String name;
  final String? sanskritName;
  final String imageUrl;
  final String badgeLabel;
  final String sectionLabel;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sanskritName = this.sanskritName;

    return AppCardPop(
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: AppShapes.decoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RemoteImage(
                url: imageUrl,
                fallbackIcon: Icons.self_improvement,
                fallbackIconSize: AppSizes.s64,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: context.gradients.cameraScrim,
                ),
              ),
              Positioned(
                top: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSizes.s72,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ActiveMetricPill(
                    icon: Icons.self_improvement,
                    value: sectionLabel,
                    label: badgeLabel,
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.xl,
                right: AppSpacing.xl,
                child: CircularHeaderButton(
                  icon: Icons.menu_book_rounded,
                  iconColor: colors.textPrimary,
                  backgroundColor: colors.surfaceTranslucent,
                  borderColor: colors.borderMedium,
                  onPressed: onInfo,
                ),
              ),
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sanskritName != null) ...[
                      Text(
                        sanskritName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMediumMedium.copyWith(
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading2Bold.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

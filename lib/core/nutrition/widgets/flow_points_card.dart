import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class FlowPointsCard extends StatelessWidget {
  const FlowPointsCard({
    super.key,
    required this.points,
    required this.maxPoints,
    required this.headline,
    required this.message,
    this.onInfo,
  });

  final int points;
  final int maxPoints;
  final String headline;
  final String message;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: 'Nutrition',
            onTap: onInfo,
            trailing: Icon(
              Icons.info_outline_rounded,
              color: colors.textSecondary,
              size: AppSizes.s20,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$points', style: context.textTheme.displaySmall),
                      Text(
                        ' / $maxPoints',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Flow Points',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (headline.isNotEmpty)
                      Text(
                        headline,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    Text(
                      message,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

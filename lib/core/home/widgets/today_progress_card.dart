import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_opacity.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key, required this.progress});

  final TodayProgress progress;

  @override
  Widget build(BuildContext context) {
    final captionStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Progress",
                      style: context.textTheme.titleLarge,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${progress.completedCount}',
                            style: captionStyle?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${progress.totalCount} tasks complete',
                          ),
                        ],
                      ),
                      style: captionStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _PercentValue(percent: progress.percent),
            ],
          ),
          SizedBox(height: AppSpacing.xl2),
          AppProgressBar(
            progress: progress.percent / 100,
            gradient: context.gradients.full,
            glowColor: context.colors.primary,
          ),
          SizedBox(height: AppSpacing.xl),
          for (final item in progress.items) ...[
            _ProgressRow(item: item),
            if (item != progress.items.last) SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _PercentValue extends StatelessWidget {
  const _PercentValue({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$percent', style: context.textTheme.displayMedium),
        Text(
          '%',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final valueColor = item.isComplete
        ? context.colors.primary
        : context.colors.textSecondary;

    return Row(
      children: [
        Container(
          width: AppSizes.s8,
          height: AppSizes.s8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.isComplete
                ? context.colors.primary
                : context.colors.backgroundElevated,
            boxShadow: item.isComplete
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(
                        alpha: AppOpacity.buttonGlowStrong,
                      ),
                      blurRadius: AppSizes.s8,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            item.label,
            style: context.textTheme.bodyLarge?.copyWith(
              color: item.isComplete
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
            ),
          ),
        ),
        if (item.fraction.isNotEmpty)
          Text(
            item.fraction,
            style: context.textTheme.bodyLarge?.copyWith(color: valueColor),
          ),
      ],
    );
  }
}

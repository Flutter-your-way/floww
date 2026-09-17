import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key, required this.progress});

  final TodayProgress progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Progress", style: context.textTheme.titleLarge),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '${progress.completedCount} / ${progress.totalCount} tasks complete',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${progress.percent}',
                style: context.textTheme.displaySmall,
              ),
              Text(
                '%',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: progress.percent / 100,
            minHeight: AppSizes.s6,
            color: context.colors.primary,
            backgroundColor: context.colors.backgroundSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          SizedBox(height: AppSpacing.xl),
          for (final item in progress.items) ...[
            _ProgressRow(item: item),
            if (item != progress.items.last) SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final ProgressItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.s8,
          height: AppSizes.s8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.isComplete ? context.colors.primary : Colors.transparent,
            border: item.isComplete
                ? null
                : Border.all(color: context.colors.borderMedium, width: 1.5),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            item.label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: item.isComplete
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ),
        if (item.fraction.isNotEmpty)
          Text(
            item.fraction,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

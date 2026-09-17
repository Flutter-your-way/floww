import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_shapes.dart';

class FlowScoreBoostCard extends StatelessWidget {
  const FlowScoreBoostCard({super.key, required this.boosts});

  final List<FlowScoreBoost> boosts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: context.colors.primary, size: AppSizes.s20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'How to Increase Your Flow Score',
                style: context.textTheme.titleLarge,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < boosts.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Divider(height: 1, color: context.colors.borderSubtle),
              ),
            _BoostRow(boost: boosts[i]),
          ],
        ],
      ),
    );
  }
}

class _BoostRow extends StatelessWidget {
  const _BoostRow({required this.boost});

  final FlowScoreBoost boost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          boost.completed ? Icons.check_circle : Icons.circle_outlined,
          color: boost.completed
              ? context.colors.primary
              : context.colors.borderMedium,
          size: AppSizes.s24,
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            boost.label,
            style: context.textTheme.bodyLarge?.copyWith(
              color: boost.completed ? context.colors.textSecondary : null,
              decoration: boost.completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: AppShapes.decoration(
            color: context.colors.tint,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            '+${boost.points} points',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

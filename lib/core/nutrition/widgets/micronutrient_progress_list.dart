import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/nutrition/models/micronutrient_progress.dart';

class MicronutrientProgressList extends StatelessWidget {
  const MicronutrientProgressList({super.key, required this.items});

  final List<MicronutrientProgress> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              color: context.colors.borderSubtle,
            ),
          _MicronutrientRow(item: items[i]),
        ],
      ],
    );
  }
}

class _MicronutrientRow extends StatelessWidget {
  const _MicronutrientRow({required this.item});

  final MicronutrientProgress item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.s56,
            child: Text(
              item.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: AppProgressBar(progress: item.progress)),
          SizedBox(
            width: AppSizes.s96,
            child: Text.rich(
              TextSpan(
                text: item.amount,
                style: context.textTheme.labelMedium,
                children: [
                  TextSpan(
                    text: ' / ${item.goal}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

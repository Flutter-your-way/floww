import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/core/home/services/daily_quote_service.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key, required this.quote});

  final DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.lg,
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: AppSizes.s24,
            color: colors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  quote.text,
                  style: AppTypography.labelLargeMedium.copyWith(
                    color: colors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (quote.author.isNotEmpty)
                  Text(
                    '— ${quote.author}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

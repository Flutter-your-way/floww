import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';

class DailyMetricsPromptCard extends StatelessWidget {
  const DailyMetricsPromptCard({
    super.key,
    required this.data,
    required this.onAllow,
  });

  final DailyMetricsViewData data;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: data.title,
            titleStyle: context.textTheme.titleLarge,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            data.promptMessage,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: IntrinsicWidth(
              child: PillButton(
                variant: PillButtonVariant.glass,
                height: AppSizes.s32,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                label: data.allowLabel,
                labelStyle: AppTypography.bodySmallSemiBold,
                labelColor: context.colors.primary,
                onPressed: onAllow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

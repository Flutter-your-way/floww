import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class HealthMetricAboutCard extends StatelessWidget {
  const HealthMetricAboutCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: title, titleStyle: context.textTheme.titleLarge),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

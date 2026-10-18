import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class AppBulletCard extends StatelessWidget {
  const AppBulletCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.footnote,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final footnote = this.footnote;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(title: title, icon: icon, iconColor: colors.primary),
          SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.md),
            _BulletRow(text: items[i]),
          ],
          if (footnote != null) ...[
            SizedBox(height: AppSpacing.lg),
            Text(
              footnote,
              style: AppTypography.bodySmallItalic.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Container(
            width: AppSizes.s6,
            height: AppSizes.s6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

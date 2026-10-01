import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/settings/models/onboarding_answers_data.dart';

class OnboardingAnswersCard extends StatelessWidget {
  const OnboardingAnswersCard({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  final OnboardingAnswerSection section;
  final ValueChanged<OnboardingAnswerItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: section.title,
            titleStyle: AppTypography.heading4SemiBold,
          ),
          for (final item in section.items) ...[
            Divider(
              height: AppSpacing.xl2,
              thickness: AppSizes.s1,
              color: context.colors.borderSubtle,
            ),
            _OnboardingAnswerRow(item: item, onTap: () => onItemTap(item)),
          ],
        ],
      ),
    );
  }
}

class _OnboardingAnswerRow extends StatelessWidget {
  const _OnboardingAnswerRow({required this.item, required this.onTap});

  final OnboardingAnswerItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.question.title,
                  style: AppTypography.bodySmallRegularTight.copyWith(
                    color: colors.textSubtle,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  item.value,
                  style: AppTypography.bodyLargeSemiBoldTall.copyWith(
                    color: item.isAnswered
                        ? colors.textPrimary
                        : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.s20,
            color: colors.textMuted,
          ),
        ],
      ),
    );
  }
}

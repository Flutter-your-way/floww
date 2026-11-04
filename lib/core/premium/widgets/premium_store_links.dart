import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/press_scale.dart';

class PremiumStoreLink {
  const PremiumStoreLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class PremiumStoreLinks extends StatelessWidget {
  const PremiumStoreLinks({super.key, required this.links});

  final List<PremiumStoreLink> links;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.xs,
      children: [
        for (final link in links)
          PressScale(
            onTap: link.onTap,
            child: Text(
              link.label,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: context.colors.textSubtle,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.textSubtle,
              ),
            ),
          ),
      ],
    );
  }
}

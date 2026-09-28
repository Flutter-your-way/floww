import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/rolling_text.dart';

class PortionNutritionSummary extends StatelessWidget {
  const PortionNutritionSummary({
    super.key,
    required this.caloriesLabel,
    required this.proteinLabel,
    required this.carbsLabel,
    required this.fatLabel,
  });

  final String caloriesLabel;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _MacroValue(prefix: 'P:', value: proteinLabel),
          const _MacroSeparator(),
          _MacroValue(prefix: 'C:', value: carbsLabel),
          const _MacroSeparator(),
          _MacroValue(prefix: 'F:', value: fatLabel),
          const Spacer(),
          SizedBox(width: AppSpacing.md),
          RollingText(
            text: caloriesLabel,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.accentOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({required this.prefix, required this.value});

  final String prefix;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelSmall?.copyWith(
      color: context.colors.textSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(prefix, style: style),
        RollingText(text: value, style: style),
      ],
    );
  }
}

class _MacroSeparator extends StatelessWidget {
  const _MacroSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        '·',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

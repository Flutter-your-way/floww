import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';

class WorkoutNotesCard extends StatelessWidget {
  const WorkoutNotesCard({
    super.key,
    required this.notes,
    required this.emptyMessage,
    this.onEdit,
  });

  final String notes;
  final String emptyMessage;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onEdit = this.onEdit;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Workout Notes',
            trailing: onEdit == null
                ? null
                : GestureDetector(
                    onTap: onEdit,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Edit',
                      style: AppTypography.bodySmallMediumTight.copyWith(
                        color: colors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: colors.primary,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: AppShapes.decoration(
              color: colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: colors.borderSubtle, width: AppSizes.s1),
            ),
            child: Text(
              notes.isEmpty ? emptyMessage : notes,
              style: AppTypography.bodyLargeMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

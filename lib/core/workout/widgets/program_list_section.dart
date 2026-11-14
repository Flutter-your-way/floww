import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';

class ProgramListSection extends StatelessWidget {
  const ProgramListSection({
    super.key,
    required this.programs,
    required this.countLabel,
    required this.emptyMessage,
    this.onOpen,
    this.isPremiumUnlocked = true,
  });

  final List<ProgramItem> programs;
  final String countLabel;
  final String emptyMessage;
  final ValueChanged<ProgramItem>? onOpen;
  final bool isPremiumUnlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onOpen = this.onOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          programs.isEmpty ? emptyMessage : countLabel,
          style: AppTypography.bodySmallRegularTight.copyWith(
            color: colors.textSecondary,
          ),
        ),
        for (final program in programs) ...[
          SizedBox(height: AppSpacing.lg),
          AppPopReveal(
            key: ValueKey(program.id),
            appearOnMount: true,
            child: ProgramRowCard(
              program: program,
              isLocked:
                  program.isPremium && !program.isActive && !isPremiumUnlocked,
              onTap: onOpen == null ? null : () => onOpen(program),
            ),
          ),
        ],
      ],
    );
  }
}

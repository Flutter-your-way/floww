import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/animations/app_pop_reveal.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/circular_header_button.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/create_program_card.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';

class ProgramListSection extends StatelessWidget {
  const ProgramListSection({
    super.key,
    required this.title,
    required this.programs,
    required this.countLabel,
    required this.emptyMessage,
    this.onBack,
    this.onOpen,
    this.onCreate,
    this.isPremiumUnlocked = true,
  });

  final String title;
  final List<ProgramItem> programs;
  final String countLabel;
  final String emptyMessage;
  final VoidCallback? onBack;
  final ValueChanged<ProgramItem>? onOpen;
  final VoidCallback? onCreate;
  final bool isPremiumUnlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onOpen = this.onOpen;
    final onBack = this.onBack;
    final onCreate = this.onCreate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              CircularHeaderButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  HapticManager.selection();
                  onBack();
                },
              ),
              SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading4SemiBold.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    countLabel,
                    style: AppTypography.bodySmallRegularTight.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        if (programs.isEmpty)
          Text(
            emptyMessage,
            style: AppTypography.bodySmallRegularTight.copyWith(
              color: colors.textSecondary,
            ),
          ),
        for (var i = 0; i < programs.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.lg),
          AppPopReveal(
            key: ValueKey(programs[i].id),
            appearOnMount: true,
            child: ProgramRowCard(
              program: programs[i],
              isLocked:
                  programs[i].isPremium &&
                  !programs[i].isActive &&
                  !isPremiumUnlocked,
              onTap: onOpen == null ? null : () => onOpen(programs[i]),
            ),
          ),
        ],
        if (onCreate != null) ...[
          SizedBox(height: AppSpacing.xl3),
          CreateProgramCard(onTap: onCreate),
        ],
      ],
    );
  }
}

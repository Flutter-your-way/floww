import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_agenda_hero_card.dart';

class WorkoutAgendaCard extends StatelessWidget {
  const WorkoutAgendaCard({
    super.key,
    required this.agenda,
    required this.onAction,
    required this.onRemove,
  });

  final WorkoutAgendaItem agenda;
  final ValueChanged<WorkoutAgendaEntryItem> onAction;
  final ValueChanged<WorkoutAgendaEntryItem> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AgendaHeader(agenda: agenda),
        for (final entry in agenda.entries) ...[
          SizedBox(height: AppSpacing.lg),
          WorkoutAgendaHeroCard(
            entry: entry,
            onAction: () => onAction(entry),
            onRemove: () => onRemove(entry),
          ),
        ],
      ],
    );
  }
}

class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader({required this.agenda});

  final WorkoutAgendaItem agenda;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final planLabel = agenda.planLabel;
    final planProgress = agenda.planProgress;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(title: agenda.title, trailingText: agenda.progressLabel),
          if (planLabel != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              planLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmallRegularTight.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (planProgress != null) ...[
            SizedBox(height: AppSpacing.md),
            AppProgressBar(
              progress: planProgress,
              trackColor: colors.borderSubtle,
              height: AppSizes.s6,
            ),
          ],
        ],
      ),
    );
  }
}

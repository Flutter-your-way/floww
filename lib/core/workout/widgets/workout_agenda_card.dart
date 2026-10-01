import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/config/widgets/progress/app_progress_bar.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_agenda_row.dart';

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
              color: colors.primaryAlt,
              trackColor: colors.borderSubtle,
              height: AppSizes.s6,
            ),
          ],
          SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < agenda.entries.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.md),
            WorkoutAgendaRow(
              entry: agenda.entries[i],
              onAction: () => onAction(agenda.entries[i]),
              onRemove: () => onRemove(agenda.entries[i]),
            ),
          ],
        ],
      ),
    );
  }
}

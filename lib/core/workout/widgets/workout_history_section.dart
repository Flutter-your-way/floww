import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/workout_history_card.dart';

class WorkoutHistorySection extends StatelessWidget {
  const WorkoutHistorySection({super.key, required this.sessions, this.onOpen});

  final List<WorkoutHistoryItem> sessions;
  final ValueChanged<WorkoutHistoryItem>? onOpen;

  @override
  Widget build(BuildContext context) {
    final onOpen = this.onOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SectionLabel(
            label: 'Recent sessions',
            color: context.colors.backgroundPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xl2),
        for (var i = 0; i < sessions.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.xl2),
          WorkoutHistoryCard(
            session: sessions[i],
            onTap: onOpen == null ? null : () => onOpen(sessions[i]),
          ),
        ],
      ],
    );
  }
}

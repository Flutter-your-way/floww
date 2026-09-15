import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/widgets/program_row_card.dart';

class ProgramListSection extends StatelessWidget {
  const ProgramListSection({super.key, required this.programs, this.onStart});

  final List<ProgramItem> programs;
  final ValueChanged<ProgramItem>? onStart;

  @override
  Widget build(BuildContext context) {
    final onStart = this.onStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SectionLabel(
            label: 'All programs',
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < programs.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.xl2),
          ProgramRowCard(
            program: programs[i],
            onStart: onStart == null ? null : () => onStart(programs[i]),
          ),
        ],
      ],
    );
  }
}

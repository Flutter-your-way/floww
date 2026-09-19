import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/progress/models/progress_view_data.dart';
import 'package:floww/core/progress/widgets/progress_metric_tile.dart';
import 'package:floww/core/progress/widgets/progress_tone_color.dart';

class PersonalRecordsCard extends StatelessWidget {
  const PersonalRecordsCard({
    super.key,
    required this.title,
    required this.records,
  });

  final String title;
  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            titleStyle: AppTypography.heading4SemiBold,
          ),
          SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final record in records) ...[
                  Expanded(
                    child: ProgressMetricTile(
                      label: record.label,
                      value: record.value,
                      caption: record.caption,
                      valueColor: record.tone.resolveValue(context),
                    ),
                  ),
                  if (record != records.last) SizedBox(width: AppSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

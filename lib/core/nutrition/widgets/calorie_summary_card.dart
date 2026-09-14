import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/nutrition/widgets/goal_ring_summary.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    required this.goalValue,
    required this.remainingValue,
    required this.consumedValue,
    required this.shareLabel,
    required this.progress,
  });

  final String goalValue;
  final String remainingValue;
  final String consumedValue;
  final String shareLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'Calorie Summary', icon: Icons.bolt_rounded),
          SizedBox(height: AppSpacing.xl),
          GoalRingSummary(
            goalValue: goalValue,
            remainingValue: remainingValue,
            shareLabel: shareLabel,
            progress: progress,
            consumedValue: consumedValue,
            consumedUnit: 'kcal',
          ),
        ],
      ),
    );
  }
}

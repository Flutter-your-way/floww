import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/core/achievements/models/achievement.dart';
import 'package:floww/core/achievements/widgets/achievement_card.dart';

class AchievementsGrid extends StatelessWidget {
  const AchievementsGrid({super.key, required this.achievements});

  static const int _columns = 2;

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final rowCount = (achievements.length / _columns).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < _columns; column++) ...[
                  if (column > 0) SizedBox(width: AppSpacing.xl),
                  Expanded(child: _cellAt(row * _columns + column)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _cellAt(int index) {
    if (index >= achievements.length) return const SizedBox.shrink();
    return AchievementCard(achievement: achievements[index]);
  }
}

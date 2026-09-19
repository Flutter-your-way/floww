import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/achievements/models/streak_summary.dart';
import 'package:floww/core/achievements/widgets/streak_milestones_card.dart';
import 'package:floww/core/achievements/widgets/streak_stat_tile.dart';
import 'package:floww/core/achievements/widgets/streak_week_card.dart';
import 'package:floww/navigation/app_router.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class StreakAchievementsSheet extends StatelessWidget {
  const StreakAchievementsSheet({super.key, required this.summary});

  static const double _maxHeightFactor = 0.9;

  final StreakSummary summary;

  static Future<void> show(
    BuildContext context, {
    required StreakSummary summary,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => StreakAchievementsSheet(summary: summary),
    );
  }

  void _openAchievements() {
    NavigationService.instance.pop();
    NavigationService.instance.push(AppRouter.achievements);
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
        ),
        child: AppSheetPanel(
          title: 'Streak & Achievements',
          titleStyle: context.textTheme.displaySmall,
          closeButtonSize: AppSizes.s36,
          closeIconSize: AppSizes.s18,
          onClose: () => NavigationService.instance.pop(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _StreakStatsRow(summary: summary),
              SizedBox(height: AppSpacing.xl),
              StreakWeekCard(summary: summary),
              SizedBox(height: AppSpacing.xl),
              StreakMilestonesCard(
                milestones: summary.milestones,
                onSeeAll: _openAchievements,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakStatsRow extends StatelessWidget {
  const _StreakStatsRow({required this.summary});

  final StreakSummary summary;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreakStatTile(
              label: 'Current',
              value: summary.currentLabel,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StreakStatTile(label: 'Best', value: summary.bestLabel),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StreakStatTile(label: 'Month', value: summary.monthLabel),
          ),
        ],
      ),
    );
  }
}

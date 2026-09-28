import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/utils/dates/app_date_utils.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/wave/models/wave_chat_day.dart';
import 'package:floww/core/wave/widgets/wave_day_row.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class WaveHistorySheet extends StatelessWidget {
  const WaveHistorySheet({
    super.key,
    required this.days,
    required this.selectedDay,
  });

  static const String emptyMessage =
      'Your chats with WAVE are grouped by day. Once you start talking, '
      'every day shows up here.';

  final List<WaveChatDay> days;
  final DateTime selectedDay;

  static Future<WaveChatDay?> show(
    BuildContext context, {
    required List<WaveChatDay> days,
    required DateTime selectedDay,
  }) {
    return showAppFloatingSheet<WaveChatDay>(
      context: context,
      builder: (_) => WaveHistorySheet(days: days, selectedDay: selectedDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingSheet(
      child: AppSheetPanel(
        title: 'Chat History',
        closeButtonSize: AppSizes.s32,
        closeIconSize: AppSizes.s16,
        onClose: () => NavigationService.instance.pop(),
        leading: AppIconTile(
          icon: Icons.history_rounded,
          size: AppSizes.s44,
          iconSize: AppSizes.s24,
          radius: AppRadius.md,
          backgroundColor: context.colors.tint,
          borderColor: context.colors.borderGlow,
          iconColor: context.colors.primary,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (days.isEmpty)
              Text(
                emptyMessage,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            for (var index = 0; index < days.length; index++) ...[
              if (index > 0) SizedBox(height: AppSpacing.lg),
              WaveDayRow(
                day: days[index],
                isSelected: AppDateUtils.isSameDay(
                  days[index].date,
                  selectedDay,
                ),
                onTap: () => NavigationService.instance.pop(days[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

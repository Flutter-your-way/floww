import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/theme/app_typography.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/buttons/app_toggle.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/health/providers/health_provider.dart';
import 'package:floww/core/home/models/daily_metrics_view_data.dart';
import 'package:floww/core/home/providers/daily_metrics_selection_provider.dart';
import 'package:floww/core/home/services/daily_metrics_presenter.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class DailyMetricsPickerSheet extends StatelessWidget {
  const DailyMetricsPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) => const DailyMetricsPickerSheet(),
    );
  }

  void _toggle(
    DailyMetricsSelectionProvider selection,
    HealthProvider health,
    DailyMetricOption option,
  ) {
    HapticManager.selection();
    selection.toggle(
      option.kind,
      DailyMetricsPresenter.availableOf(health.vitals),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HealthProvider, DailyMetricsSelectionProvider>(
      builder: (context, health, selection, _) {
        final data = DailyMetricsPresenter.pickerOf(
          health.vitals,
          source: health.sourceName,
          selection: selection,
        );
        final colors = context.colors;

        return AppFloatingSheet(
          child: AppSheetPanel(
            title: data.title,
            subtitle: data.subtitle,
            icon: Icons.tune_rounded,
            onClose: () => NavigationService.instance.pop(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final option in data.options) ...[
                  if (option != data.options.first)
                    Divider(
                      height: AppSpacing.xl2,
                      thickness: AppSizes.s1,
                      color: colors.borderSubtle,
                    ),
                  _MetricOptionRow(
                    option: option,
                    onChanged: () => _toggle(selection, health, option),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricOptionRow extends StatelessWidget {
  const _MetricOptionRow({required this.option, required this.onChanged});

  final DailyMetricOption option;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.label,
                style: AppTypography.bodyLargeSemiBold.copyWith(
                  color: option.isAvailable
                      ? colors.textPrimary
                      : colors.textMuted,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                option.detail,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        AppToggle(
          value: option.isSelected,
          isEnabled: option.canToggle,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

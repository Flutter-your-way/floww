import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_shapes.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/buttons/custom_buttons/pill_button.dart';
import 'package:floww/config/widgets/cards/app_icon_tile.dart';
import 'package:floww/config/widgets/headers/section_label.dart';
import 'package:floww/config/widgets/sheets/app_floating_sheet.dart';
import 'package:floww/config/widgets/sheets/app_sheet_panel.dart';
import 'package:floww/core/home/models/home_view_data.dart';
import 'package:floww/navigation/services/navigation_service.dart';

class FlowModeSheet extends StatelessWidget {
  const FlowModeSheet({super.key, required this.detail, this.onStartWorkout});

  final FlowModeDetail detail;
  final VoidCallback? onStartWorkout;

  static Future<void> show(
    BuildContext context, {
    required FlowModeDetail detail,
    VoidCallback? onStartWorkout,
  }) {
    return showAppFloatingSheet<void>(
      context: context,
      builder: (_) =>
          FlowModeSheet(detail: detail, onStartWorkout: onStartWorkout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeName = detail.mode.name.toUpperCase();
    final tips = detail.tips;

    return AppFloatingSheet(
      child: AppSheetPanel(
        title: '$modeName MODE',
        closeButtonSize: AppSizes.s32,
        closeIconSize: AppSizes.s16,
        onClose: () => NavigationService.instance.pop(),
        leading: AppIconTile(
          icon: Icons.bolt,
          size: AppSizes.s44,
          iconSize: AppSizes.s24,
          radius: AppRadius.md,
          backgroundColor: context.colors.tint,
          borderColor: context.colors.borderGlow,
          iconColor: context.colors.primary,
        ),
        titleContent: _ModeTitle(
          title: '$modeName MODE',
          subtitle: detail.statusLabel,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeReasonsCard(modeName: modeName, reasons: detail.reasons),
            SizedBox(height: AppSpacing.xl),
            const SectionLabel(label: "Today's Tips"),
            for (var i = 0; i < tips.length; i++) ...[
              SizedBox(height: AppSpacing.md),
              _ModeTipRow(index: i + 1, tip: tips[i]),
              if (i < tips.length - 1) ...[
                SizedBox(height: AppSpacing.md),
                Container(
                  height: AppSizes.s1,
                  color: context.colors.borderSubtle,
                ),
              ],
            ],
          ],
        ),
        footer: Center(
          child: PillButton(
            label: "Start Today's Workout",
            icon: Icons.play_arrow_rounded,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl4),
            onPressed: onStartWorkout,
          ),
        ),
      ),
    );
  }
}

class _ModeTitle extends StatelessWidget {
  const _ModeTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ModeReasonsCard extends StatelessWidget {
  const _ModeReasonsCard({required this.modeName, required this.reasons});

  final String modeName;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: AppShapes.decoration(
        color: context.colors.tint,
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.colors.borderGlow, width: AppSizes.s1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You're in $modeName because:",
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          for (final reason in reasons) ...[
            SizedBox(height: AppSpacing.lg),
            _ModeReasonRow(reason: reason),
          ],
        ],
      ),
    );
  }
}

class _ModeReasonRow extends StatelessWidget {
  const _ModeReasonRow({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.s20,
          height: AppSizes.s20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.tint,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.borderAccent,
              width: AppSizes.s1,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            size: AppSizes.s12,
            color: context.colors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(child: Text(reason, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}

class _ModeTipRow extends StatelessWidget {
  const _ModeTipRow({required this.index, required this.tip});

  final int index;
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.s24,
          height: AppSizes.s24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.backgroundSurface,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(child: Text(tip, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_sizes.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
import 'package:floww/config/widgets/animations/app_collapsible_section.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/config/widgets/headers/card_header.dart';
import 'package:floww/core/nutrition/models/nutrition_view_data.dart';
import 'package:floww/core/nutrition/widgets/swipe_to_delete.dart';

class WaterLogCard extends StatelessWidget {
  const WaterLogCard({
    super.key,
    required this.title,
    required this.entries,
    required this.emptyMessage,
    this.foodWaterLabel,
    this.onDelete,
  });

  final String title;
  final List<WaterLogItem> entries;
  final String emptyMessage;
  final String? foodWaterLabel;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final foodWaterLabel = this.foodWaterLabel;
    final onDelete = this.onDelete;
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: context.colors.borderSubtle,
    );

    return AppCard(
      variant: AppCardVariant.sunken,
      borderColor: context.colors.borderSubtle,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: AppMotion.expand,
        curve: AppMotion.expandCurve,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(title: title),
            SizedBox(height: AppSpacing.md),
            if (foodWaterLabel != null) ...[
              _WaterRow(amount: foodWaterLabel, trailing: 'From meals'),
              if (entries.isNotEmpty) divider,
            ],
            if (entries.isEmpty && foodWaterLabel == null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  emptyMessage,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            for (var i = 0; i < entries.length; i++)
              AppCollapsibleSection(
                key: ValueKey(entries[i].id),
                visible: true,
                animateIn: true,
                child: _WaterLogEntry(
                  entry: entries[i],
                  divider: i > 0 ? divider : null,
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WaterLogEntry extends StatelessWidget {
  const _WaterLogEntry({
    required this.entry,
    required this.divider,
    required this.onDelete,
  });

  final WaterLogItem entry;
  final Widget? divider;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final onDelete = this.onDelete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?divider,
        SwipeToDelete(
          id: entry.id,
          onDelete: onDelete,
          child: _WaterRow(
            amount: entry.amountLabel,
            trailing: entry.timeLabel,
            onDelete: onDelete == null ? null : () => onDelete(entry.id),
          ),
        ),
      ],
    );
  }
}

class _WaterRow extends StatelessWidget {
  const _WaterRow({
    required this.amount,
    required this.trailing,
    this.onDelete,
  });

  final String amount;
  final String trailing;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final onDelete = this.onDelete;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Text(amount, style: context.textTheme.bodyMedium)),
          Text(
            trailing,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (onDelete != null) ...[
            SizedBox(width: AppSpacing.lg),
            _UnlogButton(onTap: onDelete),
          ],
        ],
      ),
    );
  }
}

class _UnlogButton extends StatelessWidget {
  const _UnlogButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xs),
        child: Icon(
          Icons.remove_circle_outline_rounded,
          size: AppSizes.s18,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

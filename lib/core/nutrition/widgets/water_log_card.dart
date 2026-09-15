import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/theme/app_theme_tokens.dart';
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
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: context.colors.borderSubtle,
    );

    return AppCard(
      variant: AppCardVariant.sunken,
      borderColor: context.colors.borderSubtle,
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
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) divider,
            SwipeToDelete(
              id: entries[i].id,
              onDelete: onDelete,
              child: _WaterRow(
                amount: entries[i].amountLabel,
                trailing: entries[i].timeLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterRow extends StatelessWidget {
  const _WaterRow({required this.amount, required this.trailing});

  final String amount;
  final String trailing;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

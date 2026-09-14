import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/headers/screen_title.dart';
import 'package:floww/core/nutrition/widgets/date_selector_pill.dart';

class NutritionHeader extends StatelessWidget {
  const NutritionHeader({
    super.key,
    required this.titlePrefix,
    required this.dateLabel,
    this.onPreviousDay,
    this.onNextDay,
    this.onPickDate,
  });

  final String titlePrefix;
  final String dateLabel;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ScreenTitle(eyebrow: titlePrefix, title: 'Nutrition'),
        ),
        SizedBox(width: AppSpacing.lg),
        DateSelectorPill(
          label: dateLabel,
          onPrevious: onPreviousDay,
          onNext: onNextDay,
          onTapDate: onPickDate,
        ),
      ],
    );
  }
}

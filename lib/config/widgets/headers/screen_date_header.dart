import 'package:flutter/material.dart';
import 'package:floww/config/constants/app_motion.dart';
import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';
import 'package:floww/config/widgets/headers/date_selector_pill.dart';
import 'package:floww/config/widgets/headers/screen_title.dart';

class ScreenDateHeader extends StatelessWidget {
  const ScreenDateHeader({
    super.key,
    required this.titlePrefix,
    required this.title,
    required this.dateLabel,
    this.direction = DateChangeDirection.forward,
    this.onPreviousDay,
    this.onNextDay,
    this.onPickDate,
  });

  final String titlePrefix;
  final String title;
  final String dateLabel;
  final DateChangeDirection direction;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateChangeTransition(
            value: titlePrefix,
            direction: direction,
            duration: AppMotion.fast,
            distance: AppMotion.slideDistanceSmall,
            child: ScreenTitle(eyebrow: titlePrefix, title: title),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        DateSelectorPill(
          label: dateLabel,
          direction: direction,
          onPrevious: onPreviousDay,
          onNext: onNextDay,
          onTapDate: onPickDate,
        ),
      ],
    );
  }
}

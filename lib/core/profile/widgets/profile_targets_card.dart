import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/profile/models/profile_edit_data.dart';
import 'package:floww/core/profile/widgets/profile_target_slider.dart';

typedef ProfileTargetChanged = void Function(DailyTarget target, double value);

class ProfileTargetsCard extends StatelessWidget {
  const ProfileTargetsCard({
    super.key,
    required this.specs,
    required this.labelOf,
    required this.onChanged,
  });

  final List<DailyTargetSpec> specs;
  final String Function(DailyTargetSpec spec) labelOf;
  final ProfileTargetChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.xl4),
            ProfileTargetSlider(
              spec: specs[i],
              valueLabel: labelOf(specs[i]),
              onChanged: (value) => onChanged(specs[i].target, value),
            ),
          ],
        ],
      ),
    );
  }
}

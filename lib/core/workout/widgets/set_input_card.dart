import 'package:flutter/material.dart';

import 'package:floww/config/constants/app_spacing.dart';
import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/cards/app_card.dart';
import 'package:floww/core/workout/models/active_workout_view_data.dart';
import 'package:floww/core/workout/models/add_exercise_view_data.dart';
import 'package:floww/core/workout/models/set_type.dart';
import 'package:floww/core/workout/widgets/selectable_chip.dart';
import 'package:floww/core/workout/widgets/value_stepper.dart';

class SetInputCard extends StatelessWidget {
  const SetInputCard({
    super.key,
    required this.primary,
    required this.reserve,
    required this.typeOptions,
    required this.onAdjustPrimary,
    required this.onAdjustReserve,
    required this.onSelectType,
    this.weight,
    this.onAdjustWeight,
  });

  final AddExerciseTargetItem primary;
  final AddExerciseTargetItem? weight;
  final AddExerciseTargetItem reserve;
  final List<SetTypeOption> typeOptions;
  final ValueChanged<int> onAdjustPrimary;
  final ValueChanged<int>? onAdjustWeight;
  final ValueChanged<int> onAdjustReserve;
  final ValueChanged<SetType> onSelectType;

  @override
  Widget build(BuildContext context) {
    final weight = this.weight;

    return AppCard(
      variant: AppCardVariant.sunken,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ValueStepper(
                    target: primary,
                    onAdjust: onAdjustPrimary,
                  ),
                ),
                if (weight != null) ...[
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ValueStepper(
                      target: weight,
                      onAdjust: onAdjustWeight,
                    ),
                  ),
                ],
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ValueStepper(
                    target: reserve,
                    onAdjust: onAdjustReserve,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              for (final option in typeOptions)
                SelectableChip(
                  label: option.label,
                  isSelected: option.isSelected,
                  onTap: () {
                    HapticManager.selection();
                    onSelectType(option.type);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

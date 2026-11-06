import 'package:floww/core/recovery/models/muscle_emphasis.dart';
import 'package:floww/core/recovery/services/muscle_targeting.dart';

class MuscleTargetsItem {
  const MuscleTargetsItem({
    required this.title,
    required this.targets,
    this.primaryLabel,
    this.secondaryLabel,
  });

  factory MuscleTargetsItem.of(
    MuscleTargets targets, {
    required String title,
  }) => MuscleTargetsItem(
    title: title,
    targets: targets,
    primaryLabel: targets.labelOf(MuscleEmphasis.primary),
    secondaryLabel: targets.labelOf(MuscleEmphasis.secondary),
  );

  final String title;
  final MuscleTargets targets;
  final String? primaryLabel;
  final String? secondaryLabel;
}

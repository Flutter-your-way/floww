import 'package:floww/core/recovery/models/muscle_group.dart';
import 'package:floww/core/recovery/models/muscle_recovery_status.dart';

class MuscleRecoveryItem {
  const MuscleRecoveryItem({
    required this.group,
    required this.percent,
    this.lastTrainedAt,
  });

  final MuscleGroup group;
  final int percent;
  final DateTime? lastTrainedAt;

  MuscleRecoveryStatus get status => MuscleRecoveryStatus.fromPercent(percent);
}

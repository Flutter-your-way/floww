import 'dart:ui';

import 'package:floww/core/recovery/models/muscle_group.dart';

class MuscleHitRegion {
  const MuscleHitRegion({required this.group, required this.bounds});

  final MuscleGroup group;
  final Rect bounds;
}

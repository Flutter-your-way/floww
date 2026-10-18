import 'package:floww/core/yoga/models/yoga_class_section.dart';

class YogaClassBlock {
  const YogaClassBlock({
    required this.section,
    required this.postureId,
    required this.holdSeconds,
    required this.repeats,
    required this.transitionSeconds,
  });

  final YogaClassSection section;
  final String postureId;
  final int holdSeconds;
  final int repeats;
  final int transitionSeconds;

  int get totalSeconds => (holdSeconds + transitionSeconds) * repeats;
}

class YogaClassPlan {
  const YogaClassPlan({
    required this.week,
    required this.minutes,
    required this.blocks,
    required this.isGentle,
  });

  final int week;
  final int minutes;
  final List<YogaClassBlock> blocks;
  final bool isGentle;
}

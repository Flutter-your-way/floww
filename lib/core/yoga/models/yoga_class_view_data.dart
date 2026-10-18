import 'package:floww/core/workout/models/workout_section_kind.dart';

class YogaSectionChipItem {
  const YogaSectionChipItem({required this.label, required this.status});

  final String label;
  final WorkoutSectionStatus status;
}

class YogaStepItem {
  const YogaStepItem({
    required this.counterLabel,
    required this.title,
    required this.instruction,
  });

  final String counterLabel;
  final String title;
  final String instruction;
}

class YogaClassItem {
  const YogaClassItem({
    required this.postureId,
    required this.sections,
    required this.sectionTitle,
    required this.sectionRange,
    required this.poseName,
    required this.imageUrl,
    required this.cue,
    required this.breathCue,
    required this.repeatLabel,
    required this.holdLabel,
    required this.holdProgress,
    required this.isTransition,
    required this.transitionLabel,
    required this.nextUpLabel,
    required this.progress,
    required this.poseCounterLabel,
    required this.sectionLabel,
    required this.primaryLabel,
    required this.isPaused,
    this.sanskritName,
    this.step,
    this.modificationNote,
  });

  final String postureId;
  final List<YogaSectionChipItem> sections;
  final String sectionTitle;
  final String sectionRange;
  final String poseName;
  final String? sanskritName;
  final String imageUrl;
  final String cue;
  final String breathCue;
  final String repeatLabel;
  final String holdLabel;
  final double holdProgress;
  final bool isTransition;
  final String transitionLabel;
  final String nextUpLabel;
  final double progress;
  final String poseCounterLabel;
  final String sectionLabel;
  final String primaryLabel;
  final bool isPaused;
  final YogaStepItem? step;
  final String? modificationNote;
}

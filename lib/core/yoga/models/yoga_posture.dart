import 'package:floww/core/yoga/models/yoga_caution.dart';
import 'package:floww/core/yoga/models/yoga_family.dart';
import 'package:floww/core/yoga/models/yoga_prop.dart';

class YogaModification {
  const YogaModification(this.text, {this.caution});

  final String text;
  final YogaCaution? caution;
}

class YogaPosture {
  const YogaPosture({
    required this.id,
    required this.name,
    required this.family,
    required this.summary,
    required this.goal,
    required this.entrySteps,
    required this.exitSteps,
    required this.breathCues,
    required this.alignmentCues,
    required this.avoid,
    required this.modifications,
    required this.holdSeconds,
    required this.holdGuidance,
    required this.imageUrl,
    this.sanskritName,
    this.props = const [YogaProp.mat],
    this.cautions = const {},
    this.alternativeId,
    this.isPerSide = false,
    this.isOptional = false,
    this.met = 2.5,
    this.muscleShares = const {'Core': 0.2},
  });

  final String id;
  final String name;
  final String? sanskritName;
  final YogaFamily family;
  final String summary;
  final String goal;
  final List<String> entrySteps;
  final List<String> exitSteps;
  final List<String> breathCues;
  final List<String> alignmentCues;
  final List<String> avoid;
  final List<YogaModification> modifications;
  final int holdSeconds;
  final String holdGuidance;
  final String imageUrl;
  final List<YogaProp> props;
  final Set<YogaCaution> cautions;
  final String? alternativeId;
  final bool isPerSide;
  final bool isOptional;
  final double met;
  final Map<String, double> muscleShares;

  String get title {
    final sanskrit = sanskritName;
    return sanskrit == null ? name : '$sanskrit — $name';
  }

  bool isCautionedFor(Set<YogaCaution> userCautions) =>
      cautions.any(userCautions.contains);
}

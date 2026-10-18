import 'package:floww/core/yoga/models/yoga_caution.dart';

class SuryaNamaskarStep {
  const SuryaNamaskarStep({
    required this.number,
    required this.name,
    required this.instruction,
    this.sanskritName,
    this.isOptional = false,
    this.cautions = const {},
  });

  final int number;
  final String name;
  final String? sanskritName;
  final String instruction;
  final bool isOptional;
  final Set<YogaCaution> cautions;

  String get title {
    final sanskrit = sanskritName;
    return sanskrit == null ? name : '$sanskrit — $name';
  }

  bool isSkippedFor(Set<YogaCaution> userCautions) =>
      isOptional && cautions.any(userCautions.contains);
}

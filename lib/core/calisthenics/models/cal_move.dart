import 'package:floww/core/calisthenics/models/cal_gear.dart';
import 'package:floww/core/workout/models/exercise.dart';

class CalGearRule {
  const CalGearRule({
    this.gear = const {},
    this.fallbackId,
    this.needsAll = false,
  });

  final Set<CalGear> gear;
  final String? fallbackId;
  final bool needsAll;

  bool isMetBy(Set<CalGear> owned) {
    if (gear.isEmpty) return true;
    return needsAll ? gear.every(owned.contains) : gear.any(owned.contains);
  }
}

class CalMove {
  const CalMove({
    required this.id,
    required this.name,
    required this.group,
    required this.shares,
    required this.guidelines,
    required this.mistakes,
    this.met = 4,
    this.isTimed = false,
    this.gear = const {},
    this.fallbackId,
    this.needsAll = false,
    this.kit,
  });

  final String id;
  final String name;
  final MuscleGroup group;
  final Map<String, double> shares;
  final List<String> guidelines;
  final List<String> mistakes;
  final double met;
  final bool isTimed;
  final Set<CalGear> gear;
  final String? fallbackId;
  final bool needsAll;
  final String? kit;

  CalGearRule get rule =>
      CalGearRule(gear: gear, fallbackId: fallbackId, needsAll: needsAll);
}

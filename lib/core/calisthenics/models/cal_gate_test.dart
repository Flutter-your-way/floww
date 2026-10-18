import 'package:floww/core/calisthenics/models/cal_level.dart';

class CalGateTest {
  const CalGateTest({
    required this.id,
    required this.shortName,
    required this.name,
    required this.unit,
    required this.max,
    required this.tier,
    required this.gates,
  });

  final String id;
  final String shortName;
  final String name;
  final String unit;
  final double max;
  final int tier;
  final Map<CalLevel, double> gates;

  bool hasGate(CalLevel level) => gates.containsKey(level);

  bool passes(CalLevel level, double? result) {
    final gate = gates[level];
    return gate != null && result != null && result >= gate;
  }
}

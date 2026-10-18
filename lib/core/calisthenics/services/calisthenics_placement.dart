import 'package:floww/core/calisthenics/data/calisthenics_gates_data.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';

class CalGateScore {
  const CalGateScore({required this.passed, required this.counted});

  final int passed;
  final int counted;

  bool get clears =>
      counted > 0 && passed >= counted * CalisthenicsGatesData.passThreshold;
}

class CalisthenicsPlacement {
  CalisthenicsPlacement._();

  static const List<CalLevel> _gatedLevels = [
    CalLevel.four,
    CalLevel.three,
    CalLevel.two,
  ];

  static const int _tiers = 3;

  static Map<String, double> resultsOf(Map<String, dynamic> answers) {
    final results = <String, double>{};
    for (var tier = 1; tier <= _tiers; tier++) {
      if (!showsTier(tier, results)) break;
      for (final test in CalisthenicsGatesData.ofTier(tier)) {
        if (answers[test.id] case final num value) {
          results[test.id] = value.toDouble();
        }
      }
    }
    return results;
  }

  static CalGateScore scoreOf(CalLevel level, Map<String, double> results) {
    final gates = CalisthenicsGatesData.gatesOf(level);
    var passed = 0;
    for (final test in gates) {
      if (test.passes(level, results[test.id])) passed++;
    }
    return CalGateScore(passed: passed, counted: gates.length);
  }

  static bool clears(CalLevel level, Map<String, double> results) =>
      level == CalLevel.one || scoreOf(level, results).clears;

  static CalLevel levelFor(Map<String, double> results) {
    for (final level in _gatedLevels) {
      if (clears(level, results)) return level;
    }
    return CalLevel.one;
  }

  static bool showsTier(int tier, Map<String, double> results) =>
      switch (tier) {
        1 => true,
        2 => clears(CalLevel.two, results),
        _ => clears(CalLevel.three, results),
      };
}

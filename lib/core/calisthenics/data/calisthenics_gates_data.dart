import 'package:floww/core/calisthenics/models/cal_gate_test.dart';
import 'package:floww/core/calisthenics/models/cal_level.dart';

class CalisthenicsGatesData {
  CalisthenicsGatesData._();

  static const double passThreshold = 0.8;

  static const String pushUps = 'cal_max_pushups';
  static const String dips = 'cal_max_dips';
  static const String pullUps = 'cal_max_pullups';
  static const String weightedPullUp = 'cal_test_weighted_pullup';
  static const String squats = 'cal_test_squats';
  static const String pistol = 'cal_test_pistol';
  static const String plank = 'cal_test_plank';
  static const String hollow = 'cal_test_hollow';
  static const String lSit = 'cal_test_lsit';
  static const String handstand = 'cal_test_handstand';
  static const String tuckLever = 'cal_test_tuck_lever';
  static const String advancedTuckLever = 'cal_test_adv_lever';
  static const String tuckPlanche = 'cal_test_tuck_planche';
  static const String muscleUp = 'cal_test_muscle_up';

  static const List<String> rules = [
    'Log your best clean result: strict form, full range, no kipping.',
    'Test fresh, not after hard training.',
    'If a joint hurts (sharp elbow, shoulder or wrist pain), stop: that test '
        'is "not yet", whatever the count.',
    'Leave a movement at 0 if you cannot do it yet.',
  ];

  static const List<CalGateTest> tests = [
    CalGateTest(
      id: pushUps,
      shortName: 'Push-ups',
      name: 'Strict push-ups',
      unit: 'reps',
      max: 60,
      tier: 1,
      gates: {CalLevel.two: 10, CalLevel.three: 25, CalLevel.four: 40},
    ),
    CalGateTest(
      id: dips,
      shortName: 'Dips',
      name: 'Parallel-bar dips',
      unit: 'reps',
      max: 40,
      tier: 1,
      gates: {CalLevel.two: 5, CalLevel.three: 15, CalLevel.four: 20},
    ),
    CalGateTest(
      id: pullUps,
      shortName: 'Pull-ups',
      name: 'Strict pull-ups',
      unit: 'reps',
      max: 30,
      tier: 1,
      gates: {CalLevel.two: 1, CalLevel.three: 8, CalLevel.four: 15},
    ),
    CalGateTest(
      id: squats,
      shortName: 'Squats',
      name: 'Full-depth bodyweight squats',
      unit: 'reps',
      max: 60,
      tier: 1,
      gates: {CalLevel.two: 25, CalLevel.three: 40},
    ),
    CalGateTest(
      id: plank,
      shortName: 'Plank',
      name: 'Forearm plank',
      unit: 's',
      max: 180,
      tier: 1,
      gates: {CalLevel.two: 45, CalLevel.three: 90},
    ),
    CalGateTest(
      id: pistol,
      shortName: 'Pistols / side',
      name: 'Unassisted pistol squats (per side)',
      unit: 'reps',
      max: 15,
      tier: 2,
      gates: {CalLevel.three: 1, CalLevel.four: 5},
    ),
    CalGateTest(
      id: hollow,
      shortName: 'Hollow hold',
      name: 'Hollow body hold',
      unit: 's',
      max: 90,
      tier: 2,
      gates: {CalLevel.three: 30, CalLevel.four: 45},
    ),
    CalGateTest(
      id: lSit,
      shortName: 'L-sit',
      name: 'L-sit hold',
      unit: 's',
      max: 40,
      tier: 2,
      gates: {CalLevel.three: 10, CalLevel.four: 20},
    ),
    CalGateTest(
      id: handstand,
      shortName: 'Wall handstand',
      name: 'Chest-to-wall handstand',
      unit: 's',
      max: 120,
      tier: 2,
      gates: {CalLevel.three: 30, CalLevel.four: 60},
    ),
    CalGateTest(
      id: tuckLever,
      shortName: 'Tuck lever',
      name: 'Tuck front lever hold',
      unit: 's',
      max: 30,
      tier: 2,
      gates: {CalLevel.three: 8},
    ),
    CalGateTest(
      id: tuckPlanche,
      shortName: 'Tuck planche',
      name: 'Tuck planche hold',
      unit: 's',
      max: 30,
      tier: 2,
      gates: {CalLevel.three: 5, CalLevel.four: 8},
    ),
    CalGateTest(
      id: weightedPullUp,
      shortName: 'Weighted pull-up',
      name: 'Weighted pull-up ×5 (added load, % bodyweight)',
      unit: '% BW',
      max: 80,
      tier: 3,
      gates: {CalLevel.four: 25},
    ),
    CalGateTest(
      id: advancedTuckLever,
      shortName: 'Adv. tuck lever',
      name: 'Advanced tuck front lever hold',
      unit: 's',
      max: 30,
      tier: 3,
      gates: {CalLevel.four: 8},
    ),
    CalGateTest(
      id: muscleUp,
      shortName: 'Muscle-ups',
      name: 'Strict muscle-ups',
      unit: 'reps',
      max: 15,
      tier: 3,
      gates: {CalLevel.four: 1},
    ),
  ];

  static List<CalGateTest> ofTier(int tier) => [
    for (final test in tests)
      if (test.tier == tier) test,
  ];

  static List<CalGateTest> gatesOf(CalLevel level) => [
    for (final test in tests)
      if (test.hasGate(level)) test,
  ];
}
